# frozen_string_literal: true

require_relative 'base'

require 'libis/tools/extend/hash'
require 'libis/format/tool/pdf_tool'
require 'libis/format/tool/pdf_to_pdfa'
require 'libis/format/tool/pdfa_validator'
require 'libis/format/tool/pdf_optimizer'

module Libis
  module Format
    module Converter
      class PdfConverter < Libis::Format::Converter::Base
        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)

          %i[PDF PDFA]
        end

        def pdf_convert(_)
          # force usage of this converter
        end

        # Set metadata for Pdf file
        #
        # valid metadata keys are):
        #       - title
        #       - author
        #       - creator
        #       - keywords
        #       - subject
        #
        # @param [Hash] values list of metadata values to set
        def metadata(values = {})
          values.key_strings_to_symbols!
          values.each do |k, v|
            next unless %i[title author creator keywords subject].include?(k)
            (@options[:metadata] ||= {})[k] = v
          end
        end

        # Select a partial list of pages
        # @param [String] selection as described in com.itextpdf.text.pdf.SequenceList: [!][o][odd][e][even]start-end
        def range(selection)
          @options[:select] = {range: [selection].flatten.compact.join(',')}
        end

        # Create or use a watermark image.
        #
        # The watermark options are (use symbols):
        #     - text: text to create a watermark from
        #     - file: watermark image to use
        #     - image: same as above
        #     - rotation: rotation of the watermark text (in degrees; integer number)
        #     - size: font size of the watermark text
        #     - opacity: opacity of the watermark (fraction 0.0 - 1.0)
        #     - gap: size of the gap between watermark instances. Integer value is absolute size in points (1/72 inch).
        #            Fractions are percentage of widht/height.
        # If both options are given, the file will be used as-is if it exists and is a valid image file. Otherwise the
        # file will be created or overwritten with a newly created watermark image.
        #
        # The created watermark file will be a PNG image with transparent background containing the supplied text
        # slanted by 30 degrees counter-clockwise.
        #
        # @param [Hash] options Hash of options for watermark creation.
        def watermark(options = {})
          options.key_strings_to_symbols!
          if options[:file] || options[:image]
            watermark_image(options)
          elsif options[:text]
            watermark_text(options)
          elsif options[:banner]
            watermark_banner(options)
          end
        end

        def watermark_image(options = {})
          options.key_strings_to_symbols!
          @options[:watermark] = {command: 'image'}
          @options[:watermark][:data] = options[:file] || options[:image]
          @options[:watermark][:opacity] = options[:opacity] || '0.3'

        end

        def watermark_text(options = {})
          options.key_strings_to_symbols!
          @options[:watermark] = {command: 'text'}
          @options[:watermark][:data] = (options[:text] || '© LIBIS').split('\n')
          @options[:watermark][:rotation] = options[:rotation] if options[:rotation]
          @options[:watermark][:size] = options[:size] if options[:size]
          @options[:watermark][:gap] = options[:gap] if options[:gap].to_s =~ /^\s*\d+\s*$/
          @options[:watermark][:padding] = options[:gap] if options[:gap].to_s =~ /^\s*(0+\.\d+|1\.0+)\s*$/
          @options[:watermark][:padding] = options[:padding] if options[:padding]
          @options[:watermark][:opacity] = options[:opacity] || '0.3'
        end

        # Create a vertical banner to the right side of each page
        #
        # The banner options are:
        # - banner: text to put in the banner
        # - add_filename: append filename to the text (use any value to enable)
        # - fontsize: size of the font (in points)
        # - width: width of the banner
        # - (background|text)_color_(red|green|blue): color components of background and text
        def watermark_banner(options = {})
          options.key_strings_to_symbols!
          @options[:watermark] = {command: 'banner'}
          @options[:watermark][:data] = (options[:banner] || '© LIBIS')
          @options[:watermark][:add_filename] = !!options[:add_filename]
          @options[:watermark][:size] = options[:fontsize] if options[:fontsize]
          @options[:watermark][:width] = options[:width] if options[:width]
          @options[:watermark][:background_red] = options[:background_color_red] if options[:background_color_red]
          @options[:watermark][:background_green] = options[:background_color_green] if options[:background_color_green]
          @options[:watermark][:background_blue] = options[:background_color_blue] if options[:background_color_blue]
          @options[:watermark][:text_red] = options[:text_color_red] if options[:text_color_red]
          @options[:watermark][:text_green] = options[:text_color_green] if options[:text_color_green]
          @options[:watermark][:text_blue] = options[:text_color_blue] if options[:text_color_blue]
        end

        # Optimize the PDF
        #
        # This reduces the graphics quality to a level in order to limit file size. This option relies on the
        # presence of ghostscript and takes one argument: the quality level. It should be one of:
        #
        # - 0 : lowest quality (Acrobat Distiller 'Screen Optimized' equivalent)
        # - 1 : medium quality (Acrobat Distiller 'eBook' equivalent)
        # - 2 : good quality (Acrobat Distiller 'Default' equivalent)
        # - 3 : high quality (Acrobat Distiller 'Print Optimized' equivalent)
        # - 4 : highest quality (Acrobat Distiller 'Prepress Optimized' equivalent)
        #
        # Note that the optimization is intended to be used with PDF's containing high-resolution images.
        #
        # @param [Integer] setting quality setting. [0-4]
        def optimize(setting = 1)
          @options[:optimize] = %w[screen ebook default printer prepress][setting] if (0..4).include?(setting)
        end

        def convert(source, target, format, opts = {})
          super

          result = nil

          unless @options.empty?
            result = convert_pdf(source, target)
            source = result
          end

          if source && (quality = @options.delete(:optimize))
            result = optimize_pdf(source, target, quality)
            source = result
          end

          if source && (format == :PDFA)
            result = pdf_to_pdfa(source, target)
          end

          {
            files: [result],
            converter: self.class.name
          }
        end

        protected

        def optimize_pdf(source, target, quality)
          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfOptimizer.run(source, tmpname, quality)
            unless result[:err].empty?
              error("Pdf optimization encountered errors:\n%s", (result[:err] + result[:out]).join("\n"))
              return nil
            end
            tmpname
          end
        end

        def convert_pdf(source, target)
          result = source
          result = add_watermark(result, target, @options[:watermark]) if @options[:watermark]
          result = add_metadata(result, target, @options[:metadata]) if @options[:metadata]
          result = select_range(result, target, @options[:select]) if @options[:select]
          return result
        end

        def options_to_args(options)
          options.map do |k, v|
            key = "--#{k.to_s.tr_s('_', '-')}"
            value = v
            case value
            when TrueClass
              value = nil
            when FalseClass
              value = key = nil
            when Array
              value = value.map(&:to_s)
            else
              value = v.to_s
            end
            [key, value]
          end.flatten.compact
        end

        def add_watermark(source, target, options)
          command = options.delete(:command)
          data = [options.delete(:data)].flatten.compact
          args = data + options_to_args(options)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfTool.run(['watermark', command], source, tmpname, *args)
            unless result[:err].empty?
              error("Pdf watermarking encountered errors:\n%s", result[:err].join(join("\n")))
              return nil
            end
            tmpname
          end
        end

        def add_metadata(source, target, options)
          args = options_to_args(options)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfTool.run('metadata', source, tmpname, *args)
            unless result[:err].empty?
              error("Pdf metadata encountered errors:\n%s", result[:err].join(join("\n")))
              return nil
            end
            tmpname
          end
        end

        def select_range(source, target, options)
          args = options_to_args(options)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfTool.run('select', source, tmpname, *args)
            unless result[:err].empty?
              error("Pdf select encountered errors:\n%s", result[:err].join(join("\n")))
              return nil
            end
            tmpname
          end
        end

        def pdf_to_pdfa(source, target)
          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfToPdfa.run source, tmpname

            unless result[:status].zero?
              error("Pdf/A conversion encountered errors:\n%s", (result[:out] + result[:err]).join("\n"))
              return nil
            else
              r = Libis::Format::Tool::PdfaValidator.run tmpname
              if r[:status] != 0
                error "Pdf/A file failed to validate with following errors:\n%s", (r[:err] || r[:out] || []).join("\n")
                return nil
              end
            end
            tmpname
          end
        end
      end
    end
  end
end
