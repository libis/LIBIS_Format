# encoding: utf-8

require_relative 'base'
require 'libis/format/identifier'

require 'mini_magick'
# noinspection RubyResolve
require 'fileutils'

MiniMagick.logger.level = ::Logger::UNKNOWN

MiniMagick.configure do |config|
  # config.cli = :graphicsmagick
  config.validate_on_create = false
  config.validate_on_write = false
  config.whiny = false
end

module Libis
  module Format
    module Converter

      # noinspection RubyTooManyInstanceVariablesInspection
      class ImageWatermarker < Libis::Format::Converter::Base

        def self.input_types
          [:TIFF, :JPG, :PNG, :BMP, :GIF, :PDF, :JP2]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [format]
        end

        def self.multipage?(format)
          [:PDF, :TIFF, :GIF, :PBM, :PGM, :PPM].include?(format)
        end

        def initialize
          super
          @quiet = true
          @wm_image = nil
          @wm_file = nil
          @wm_text = '© LIBIS'
          @wm_tiles = 4
          @wm_resize = nil
          @wm_gap = 20
          @wm_gravity = 'Center'
          @wm_rotation = 30
          @wm_composition ='modulate'
          @wm_composition_args = '10'
        end

        def image_watermark(_)
          #force usage of this converter
          self
        end

        def quiet(v)
          @quiet = !!v
          self
        end

        def page(v)
          @page = v.to_i
          self
        end

        # watermark image to use
        def file(v)
          @wm_file = v.blank? ? nil : v
          self
        end

        # text to create a watermark from
        def text(v)
          @wm_text = v.blank? ? nil : v
          self
        end

        # rotation of the watermark text (counter clockwise in degrees; integer number)
        # default 30
        def rotation(v)
          @wm_rotation = v.to_i
          self
        end

        # number of tiles of the watermark
        # default 4
        # 0: no tiling, so only 1 watermark will be placed with the original size
        # 1: 1 tile, so the watermark will be scaled up to fill the image
        # n > 1: minimum n tiles in both directions
        # n < 0: tile without scaling the watermark
        def tiles(v)
          @wm_tiles = v.to_i
          self
        end

        # fraction 0.0 - 1.0
        def resize(v)
          @wm_resize = (v.to_f * 100).to_i
          self
        end

        # size of the gap between watermark instances. Fractions as percentage of widht/height
        # default 0.2
        def gap(v)
          @wm_gap = (v.to_f * 100).to_i
          self
        end

        # center point for the watermark overlay
        # default 'center'
        def gravity(v)
          @wm_gravity = v.blank? ? nil : v
          self
        end

        # the image composition method for merging the watermark image
        # default 'modulate'
        # See https://imagemagick.org/script/compose.php for more information
        def composition(v)
          @wm_composition = v.blank? ? nil : v
          self
        end

        # arguments for the composition method
        # default '10'
        # See https://imagemagick.org/script/compose.php for more information
        def composition_args(v)
          @wm_composition_args = v.blank? ? nil : v
          self
        end


        def convert(source, target, format, opts = {})
          super

          FileUtils.mkpath(File.dirname(target))

          if source.is_a?(Array) || File.directory?(source)
            error 'Only a single image file is allowed for input'
          else
            image = MiniMagick::Image.open(source) { |b| b.quiet }

            if image.pages.size > 1
              if @page
                convert_image(image.pages[@page].path, target, format)
              else
                error 'multipage input file detecte; you need to supply a page number'
              end
            else
              convert_image(source, target, format)
            end
          end

          target

        end

        protected

        # noinspection DuplicatedCode
        def convert_image(source, target, format)

          wm_image = watermark_image
          return nil unless wm_image
          image_info = MiniMagick::Image::Info.new(source) {|b| b.quiet}

          MiniMagick::Tool::Convert.new do |convert|
            convert.quiet if @quiet

            # adapt watermark image to tile size and apply gap and resize if necessary
            convert << @wm_image.path
            # noinspection RubyResolve
            convert.bordercolor('transparent').border("#{@wm_gap}%") if @wm_gap > 0
            convert.filter('Lagrange')
            convert.resize("#{image_info['width'] / @wm_tiles}x#{image_info['height'] / @wm_tiles}") if @wm_tiles > 0
            convert.resize("#{@wm_resize}%") if @wm_resize
            convert.write('mpr:watermark').delete.+

            # convert the source image
            convert << source
            if @wm_tiles >= 0 and @wm_tiles <= 1
              # only 1 watermark required (tiles = 0/1 => scaled no/yes)
              convert << 'mpr:watermark'
            else
              # fill the image size with a pattern of the watermark image
              convert.stack do |stack|
                stack.size("#{image_info['width']}x#{image_info['height']}")
                stack << 'xc:transparent'
                # noinspection RubyResolve
                stack.tile('mpr:watermark')
                # noinspection RubyResolve
                stack.draw "rectangle 0,0,#{image_info['width']},#{image_info['height']}"
              end
            end
            # perform the blending operation
            convert.compose(@wm_composition).gravity(@wm_gravity).define("compose:args=#{@wm_composition_args}").composite

            convert.format(format)
            convert << target

            debug "ImageMagick command: '#{convert.command.join(' ')}'"
          end

          target

        end

        private

        # Create or use a watermark image.
        #
        # If both text and image are set, the file will be used as-is if it exists and is a valid image file. Otherwise the
        # file will be created or overwritten with a newly created watermark image.
        #
        # The created watermark file will be a 2000x2000 pixels PNG image with transparent background
        #
        # The text will be slanted by given rotation degrees counter-clockwise
        def watermark_image
          rotation = 360 - @wm_rotation
          @wm_image = MiniMagick::Image.new(@wm_file) if @wm_file
          # only create image if file is not an image
          unless @wm_image&.valid?
            # noinspection RubyResolve
            # Create image file (as given or temp file)
            image = @wm_file || (Dir::Tmpname.create(%w(wm_image .png)) {|_|})
            # noinspection RubyResolve
            MiniMagick::Tool::Convert.new do |convert|
              convert.quiet # allways quiet
              convert.background 'transparent'
              convert.size('2000x2000')
              convert.gravity 'Center'
              convert.font('Helvetica').fill('black').pointsize(72) #.stroke('black').strokewidth(1)
              convert << "label:#{@wm_text}"
              convert.rotate rotation
              convert.trim.repage.+
              convert << image
            end
            if @wm_file
              @wm_image = MiniMagick::Image.new(image)
            else # delete temp file
              @wm_image = MiniMagick::Image.open(image)
              File.delete(image)
            end
            # noinspection RubyResolve
            unless @wm_image.valid?
              error "Problem creating watermark image '#{image}'."
              @wm_image = nil
            end
            @wm_image
          end
        end


      end

    end
  end
end