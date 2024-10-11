# frozen_string_literal: true

require_relative 'base'
require 'libis/format/identifier'

require 'mini_magick'
require 'fileutils'

MiniMagick.logger.level = ::Logger::UNKNOWN

MiniMagick.configure do |config|
  config.tmpdir = Libis::Format::Config[:tempdir] || Dir.tmpdir
end

module Libis
  module Format
    module Converter
      # noinspection RubyTooManyInstanceVariablesInspection
      class ImageConverter < Libis::Format::Converter::Base
        def self.input_types
          %i[TIFF JPG PNG BMP GIF PDF JP2]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)

          %i[TIFF JPG PNG BMP GIF PDF JP2]
        end

        def self.multipage?(format)
          %i[PDF TIFF GIF PBM PGM PPM].include?(format)
        end

        def initialize
          @wm_image = nil
          super
        end

        def image_convert(_)
          # force usage of this converter
        end

        def quiet(value)
          @quiet = !!value
        end

        def page(number)
          @page = number
        end

        def scale(percent)
          @options[:scale] = percent
        end

        def resize(geometry)
          @options[:resize] = geometry
        end

        def quality(value)
          @options[:quality] = value
        end

        def dpi(value)
          @options[:density] = value
        end

        def resample(value)
          @options[:resample] = value
        end

        def flatten(value = true)
          @options[:flatten] = !!value
        end

        def colorspace(value)
          @options[:colorspace] = value
        end

        def delete_date(value = true)
          @delete_date = !!value
        end

        def profile(icc)
          @profile = icc
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

        # Use an image as watermark
        #
        # Next to the :file or :image option, this enables the following options:
        # - tiles: number of tiles of the watermark - default 4
        #     0: no tiling, so only 1 watermark will be placed with the original size
        #     1: 1 tile, so the watermark will be scaled up to fill the image
        #     n > 1: minimum n tiles in both directions
        #     n < 0: tile without scaling the watermark
        # - size: same as tiles - for backwards compatibility
        # - resize: fraction 0.0 - 1.0
        # - gap: size of the gap between watermark instances. Fractions as percentage of widht/height. - default 0.2
        # - opacity: opacity of the watermark (fraction 0.0 - 1.0) - default 0.1
        # - gravity: center point of the overlay - default 'center'
        # - composition: algorithm to use to compose both images - default modulate
        def watermark_image(options = {})
          options.key_strings_to_symbols!
          @options[:watermark] = {command: 'image'}
          @options[:watermark][:data] = options[:file] || options[:image]
          @options[:watermark][:tiles] = (options[:tiles] || options[:size] || 4).to_i
          @options[:watermark][:resize] = ((options[:resize]).to_f * 100).to_i if options[:resize]
          @options[:watermark][:gap] = ((options[:gap] || 0.2).to_f * 100).to_i
          @options[:watermark][:opacity] = ((options[:opacity] || 0.1).to_f * 100).to_i
          @options[:watermark][:gravity] = options[:gravity] || 'center'
          @options[:watermark][:composition] = options[:composition] || 'modulate'
          @options[:watermark][:rotation] = 360 - (options[:rotation] || 30).to_i
        end

        # Use text as watermark
        #
        # Next to the :text option, this enables the following options:
        # - tiles: number of tiles of the watermark - default 4
        #     0: no tiling, so only 1 watermark will be placed with the original size
        #     1: 1 tile, so the watermark will be scaled up to fill the image
        #     n > 1: minimum n tiles in both directions
        #     n < 0: tile without scaling the watermark
        # - size: same as tiles - for backwards compatibility
        # - resize: fraction 0.0 - 1.0
        # - gap: size of the gap between watermark instances. Fractions as percentage of widht/height. - default 0.2
        # - opacity: opacity of the watermark (fraction 0.0 - 1.0) - default 0.1
        # - gravity: center point of the overlay - default 'center'
        # - composition: algorithm to use to compose both images - default modulate
        # - rotation: rotation of the text
        def watermark_text(options = {})
          options.key_strings_to_symbols!
          @options[:watermark] = {command: 'text'}
          @options[:watermark][:data] = options[:text] || '© LIBIS'
          @options[:watermark][:tiles] = (options[:tiles] || options[:size] || 4).to_i
          @options[:watermark][:resize] = ((options[:resize]).to_f * 100).to_i if options[:resize]
          @options[:watermark][:gap] = ((options[:gap] || 0.2).to_f * 100).to_i
          @options[:watermark][:opacity] = ((options[:opacity] || 0.1).to_f * 100).to_i
          @options[:watermark][:gravity] = options[:gravity] || 'center'
          @options[:watermark][:composition] = options[:composition] || 'modulate'
          @options[:watermark][:rotation] = 360 - (options[:rotation] || 30).to_i
        end

        # Create a vertical banner to the right side of each page
        #
        # The banner options are:
        # - banner: text to put in the banner
        # - add_filename: append filename to the text (use any value to enable)
        # - fontsize: size of the font (in points) (default: autoscale)
        # - width: width of the banner (default: 3% of image height). Not including a border of 30% of the banner width
        # - background_color_(red|green|blue): color components of background (default: rgb(84,190,233))
        # - text_color_(red|green|blue): color components of background (default: rgb(255,255,255))
        def watermark_banner(options = {})
          options.key_strings_to_symbols!
          @options[:watermark] = {command: 'banner'}
          @options[:watermark][:data] = options[:banner] || '© LIBIS'
          @options[:watermark][:add_filename] = !!options[:add_filename]
          @options[:watermark][:size] = options[:fontsize] if options[:fontsize]
          @options[:watermark][:width] = options[:width] if options[:width]
          @options[:watermark][:background_red] = options[:background_color_red] || 84
          @options[:watermark][:background_green] = options[:background_color_green] || 190
          @options[:watermark][:background_blue] = options[:background_color_blue] || 233
          @options[:watermark][:text_red] = options[:text_color_red] || 255
          @options[:watermark][:text_green] = options[:text_color_green] || 255
          @options[:watermark][:text_blue] = options[:text_color_blue] || 255
        end

        def convert(source, target, format, opts = {})
          super

          FileUtils.mkpath(File.dirname(target))

          if source.is_a? Array

            assemble_and_convert(source, target, format)

          elsif File.directory?(source)
            source_list = Dir[File.join(source, '**', '*')].reject { |p| File.directory? p }

            assemble_and_convert(source_list, target, format)

          else

            image = MiniMagick::Image.open(source) { |b| b.quiet } # rubocop:disable Style/SymbolProc

            if image.pages.size > 1
              if @page
                convert_image(image.pages[@page].path, target, format)
              else
                # noinspection RubyBlockToMethodReference
                assemble_and_convert(image.pages.map(&:path), target, format)
              end
            else
              convert_image(source, target, format)
            end
          end

          {
            files: [target],
            converter: self.class.name
          }
        end

        def assemble_and_convert(sources, target, format)
          warn 'Received multiple images as input and single page format as target.' unless self.class.multipage?(format)
          converted_pages = sources.inject([]) do |list, path|
            # noinspection RubyArgCount
            converted = Tempfile.new(['page-', ".#{Libis::Format::TypeDatabase.type_extentions(format).first}"])
            convert_image(path, converted.path, format)
            list << converted
          end
          MiniMagick.convert do |b|
            b.append unless self.class.multipage?(format)
            converted_pages.each { |page| b << page.path }
            b << target
          end
          converted_pages.each do |temp_file|
            temp_file.close
            temp_file.unlink
          end
        end

        protected

        def convert_image(source, target, format)
          image_info = nil

          MiniMagick.convert do |convert|
            # Make converter silent
            convert.quiet if @quiet

            # Build watermark image in buffer
            wm = @options.delete(:watermark)
            if wm
              image_info = MiniMagick::Image::Info.new(source) { |b| b.quiet }
              case wm[:command]
              when 'text'
                convert.background 'transparent'
                convert.size('2000x2000')
                convert.gravity 'Center'
                convert.font('Helvetica').fill('black').pointsize(72) # .stroke('black').strokewidth(1)
                convert << "label:#{wm[:data]}"
                convert.rotate wm[:rotation]
                convert.trim.repage.+ # rubocop:disable Lint/Void
                convert.bordercolor('transparent').border("#{wm[:gap]}%") if wm[:gap].positive?
                convert.filter('Lagrange')
                convert.resize("#{image_info['width'] / wm[:tiles]}x#{image_info['height'] / wm[:tiles]}") if wm[:tiles].positive?
                convert.resize("#{wm[:resize]}%") if wm[:resize]
              when 'image'
                convert << wm[:data]
                convert.background 'transparent'
                convert.bordercolor('transparent').border("#{wm[:gap]}%") if wm[:gap].positive?
                convert.rotate wm[:rotation]
                convert.filter('Lagrange')
                convert.resize("#{image_info['width'] / wm[:tiles]}x#{image_info['height'] / wm[:tiles]}") if wm[:tiles].positive?
                convert.resize("#{wm[:resize]}%") if wm[:resize]
              when 'banner'
                banner_width = wm[:width] || [0.03 * image_info['height'], 20].max.round(0)
                banner_border = banner_width / 3
                convert.background "rgb(#{wm[:background_red]},#{wm[:background_green]},#{wm[:background_blue]})"
                convert.size("#{image_info['height']}x#{banner_width}")
                convert.bordercolor "rgb(#{wm[:background_red]},#{wm[:background_green]},#{wm[:background_blue]})"
                convert.border "0x#{banner_border}"
                convert.fill "rgb(#{wm[:text_red]},#{wm[:text_green]},#{wm[:text_blue]})"
                convert.font "Liberation-Sans"
                convert.pointsize wm[:size] if wm[:size]
                convert.gravity 'Center'
                convert << "label:#{wm[:data]}#{wm[:add_filename] ? File.basename(source, '.*') : ''}"
              end

              # Save watermark image to buffer
              convert.write('mpr:watermark').delete.+
            end

            # load source image
            convert << source

            # force flatten image if necessary
            convert.flatten if @options[:flatten].nil? && format == :JPG

            # add watermark image
            if wm
              if wm[:command] == 'banner'
                convert.rotate '-90'
                convert << 'mpr:watermark'
                convert.rotate '180'
                convert.append
                convert.rotate '-90'
              else
                if (0..1).include? wm[:tiles]
                  convert << 'mpr:watermark'
                else
                  convert.stack do |stack|
                    stack.size("#{image_info['width']}x#{image_info['height']}")
                    stack << 'xc:transparent'
                    stack.tile('mpr:watermark')
                    stack.draw "rectangle 0,0,#{image_info['width']},#{image_info['height']}"
                  end
                  convert.compose(wm[:composition])
                  convert.gravity(wm[:gravity])
                  convert.define("compose:args=#{wm[:opacity]}%")
                  convert.composite
                end
              end
            end

            @flags.each { |f, v| v.is_a?(TrueClass) ? convert.send(f).+ : convert.send(f) }
            convert << '+set' << 'modify-date' << '+set' << 'create-date' if @delete_date

            colorspace = @options.delete(:colorspace) || 'sRGB'
            unless @options.empty?
              convert.colorspace('RGB')
              @options.each { |o, v| convert.send(o, v) }
            end
            convert.colorspace(colorspace)
            convert.profile @profile if @profile

            convert.format(format)
            convert << target

            debug "ImageMagick command: '#{convert.command.join(' ')}'"
          end

          target
        end
      end
    end
  end
end
