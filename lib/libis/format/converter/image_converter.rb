# frozen_string_literal: true

require_relative 'base'
require 'libis/format/identifier'

require 'mini_magick'
require 'fileutils'

MiniMagick.logger.level = ::Logger::UNKNOWN

MiniMagick.configure do |config|
  # config.cli = :graphicsmagick
  config.validate_on_create = false
  config.validate_on_write = false
  config.whiny = false
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
        # The watermark options are:
        #     - file: watermark image to use
        #     - text: text to create a watermark from
        #     - rotation: rotation of the watermark text (counter clockwise in degrees; integer number) - default 30
        #     - tiles: number of tiles of the watermark - default 4
        #       - 0: no tiling, so only 1 watermark will be placed with the original size
        #       - 1: 1 tile, so the watermark will be scaled up to fill the image
        #       - n > 1: minimum n tiles in both directions
        #       - n < 0: tile without scaling the watermark
        #     - size: same as tiles - for backwards compatibility
        #     - resize: fraction 0.0 - 1.0
        #     - gap: size of the gap between watermark instances. Fractions as percentage of widht/height. - default 0.2
        #     - opacity: opacity of the watermark (fraction 0.0 - 1.0) - default 0.1
        #     - gravity: center point of the overlay - default 'center'
        # If both options are given, the file will be used as-is if it exists and is a valid image file. Otherwise the
        # file will be created or overwritten with a newly created watermark image.
        #
        # The created watermark file will be a PNG image with transparent background containing the supplied text
        # slanted by 30 degrees counter-clockwise.
        #
        # @param [Hash] options Hash of options for watermark creation.
        def watermark(options = {})
          text = options[:text] || '© LIBIS'
          @wm_tiles = (options[:tiles] || '4').to_i
          @wm_tiles ||= (options[:size] || '4').to_i
          @wm_resize = ((options[:resize]).to_f * 100).to_i if options[:resize]
          @wm_opacity = ((options[:opacity] || 0.1).to_f * 100).to_i
          @wm_composition = options[:composition] || 'modulate'
          @wm_gravity = options[:gravity] || 'center'
          @wm_gap = ((options[:gap] || 0.2).to_f * 100).to_i
          rotation = 360 - (options[:rotation] || 30).to_i
          @wm_image = MiniMagick::Image.new(options[:file]) if options[:file]
          return if @wm_image&.valid?

          image = options[:file] || (Dir::Tmpname.create(%w[wm_image .png]) { |_| })
          # noinspection RubyResolve
          MiniMagick::Tool::Convert.new do |convert|
            # noinspection RubyLiteralArrayInspection
            convert.quiet
            convert.background 'transparent'
            convert.size('2000x2000')
            convert.gravity 'Center'
            convert.font('Helvetica').fill('black').pointsize(72) # .stroke('black').strokewidth(1)
            convert << "label:#{text}"
            convert.rotate rotation
            convert.trim.repage.+ # rubocop:disable Lint/Void
            convert << image
          end
          if options[:file]
            @wm_image = MiniMagick::Image.new(image)
          else
            @wm_image = MiniMagick::Image.open(image)
            File.delete(image)
          end
          # noinspection RubyResolve
          return if @wm_image.valid?

          error "Problem creating watermark image '#{image}'."
          @wm_image = nil
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
          MiniMagick::Tool::Convert.new do |b|
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
          image_info = MiniMagick::Image::Info.new(source) { |b| b.quiet } if @wm_image # rubocop:disable Style/SymbolProc

          MiniMagick::Tool::Convert.new do |convert|
            convert.quiet if @quiet
            if @wm_image
              convert << @wm_image.path
              convert.bordercolor('transparent').border("#{@wm_gap}%") if @wm_gap.positive?
              convert.filter('Lagrange')
              convert.resize("#{image_info['width'] / @wm_tiles}x#{image_info['height'] / @wm_tiles}") if @wm_tiles.positive?
              convert.resize("#{@wm_resize}%") if @wm_resize
              convert.write('mpr:watermark').delete.+
            end

            convert.quiet if @quiet
            convert << source
            convert.flatten if @options[:flatten].nil? && format == :JPG
            if @wm_image
              if (@wm_tiles >= 0) && (@wm_tiles <= 1)
                convert << 'mpr:watermark'
              else
                convert.stack do |stack|
                  stack.size("#{image_info['width']}x#{image_info['height']}")
                  stack << 'xc:transparent'
                  stack.tile('mpr:watermark')
                  stack.draw "rectangle 0,0,#{image_info['width']},#{image_info['height']}"
                end
              end
              convert.compose(@wm_composition).gravity(@wm_gravity).define("compose:args=#{@wm_opacity}%").composite
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
