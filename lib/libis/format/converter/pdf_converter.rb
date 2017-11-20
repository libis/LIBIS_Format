# encoding: utf-8

require_relative 'base'

require 'libis/tools/extend/hash'
require 'libis/format/pdf_copy'
require 'libis/format/pdf_to_pdfa'
require 'libis/format/pdf_optimizer'

module Libis
  module Format
    module Converter

      class PdfConverter < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)
          [:PDF, :PDFA]
        end

        def pdf_convert(_)
          #force usage of this converter
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
            next unless [:title, :author, :creator, :keywords, :subject].include?(k)
            @options["md_#{k}"] = v
          end
        end

        # Select a partial list of pages
        # @param [String] selection as described in com.itextpdf.text.pdf.SequenceList: [!][o][odd][e][even]start-end
        def range(selection)
          @options[:ranges] = selection
        end

        # Create or use a watermark image.
        #
        # The watermark options are (use symbols):
        #     - text: text to create a watermark from
        #     - file: watermark image to use
        #     - rotation: rotation of the watermark text (in degrees; integer number)
        #     - size: font size of the watermark text
        #     - opacity: opacity of the watermark (fraction 0.0 - 1.0)
        #     - gap: size of the gap between watermark instances. Integer value is absolute size in points (1/72 inch). Fractions are percentage of widht/height.
        # If both options are given, the file will be used as-is if it exists and is a valid image file. Otherwise the
        # file will be created or overwritten with a newly created watermark image.
        #
        # The created watermark file will be a PNG image with transparent background containing the supplied text
        # slanted by 30 degrees counter-clockwise.
        #
        # @param [Hash] options Hash of options for watermark creation.
        def watermark(options = {})
          options.key_strings_to_symbols!
          if options[:file] && File.exist?(options[:file])
            @options['wm_image'] = options[:file]
          else
            @options['wm_text'] = (options[:text] || '© LIBIS').split('\n')
            @options['wm_text_rotation'] = options[:rotation] if options[:rotation]
            @options['wm_font_size'] = options[:size] if options[:size]
          end
          @options['wm_opacity'] = options[:opacity] || '0.3'
          @options['wm_gap_ratio'] = options[:gap] if options[:gap].to_s =~ /^\s*(0+\.\d+|1\.0+)\s*$/
          @options['wm_gap_size'] = options[:gap] if options[:gap].to_s =~ /^\s*\d+\s*$/
        end

        # Optimize the PDF
        #
        # This reduces the graphics quality to a level in order to limit file size. This option relies on the
        # presence of ghostscript and takes one argument: the quality level. It should be one of:
        #
        # - 0 : lowest quality (Acrobat Distiller 'Screen Optimized' equivalent)
        # - 1 : medium quality (Acrobat Distiller 'eBook' equivalent)
        # - 2 : good quality
        # - 3 : high quality (Acrobat Distiller 'Print Optimized' equivalent)
        # - 4 : highest quality (Acrobat Distiller 'Prepress Optimized' equivalent)
        #
        # Note that the optimization is intended to be used with PDF's containing high-resolution images.
        #
        # @param [Integer] setting quality setting. [0-4]
        def optimize(setting = 1)
          @options['optimize'] = %w(screen ebook default printer prepress)[setting] if (0..4) === setting
        end

        def convert(source, target, format, opts = {})
          super

          result = nil

          if (quality = @options.delete('optimize'))
            result = optimize_pdf(source, target, quality)
            return nil unless result
            source = result
          end

          unless @options.empty?
            result = convert_pdf(source, target)
            return nil unless result
            source = result
          end

          if format == :PDFA and source
            result = pdf_to_pdfa(source, target)
          end

          result

        end

        def optimize_pdf(source, target, quality)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfOptimizer.run(source, tmpname, quality)
            unless result[:status] == 0
              error("Pdf optimization encountered errors:\n%s", (result[:err] + result[:out]).join('\n'))
              next nil
            end
            tmpname
          end
        end

        def convert_pdf(source, target)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfCopy.run(
                source, tmpname,
                @options.map { |k, v|
                  if v.nil?
                    nil
                  else
                    ["--#{k}", (v.is_a?(Array) ? v : v.to_s)]
                  end }.flatten
            )
            unless result[:err].empty?
              error("Pdf conversion encountered errors:\n%s", result[:err].join('\n'))
              next nil
            end
            tmpname
          end

        end

        def pdf_to_pdfa(source, target)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfToPdfa.run source, tmpname
            unless result[:status] == 0
              error("Pdf/A conversion encountered errors:\n%s", result[:err].join('\n'))
              next nil
            end
            tmpname
          end

        end

      end

    end
  end
end
