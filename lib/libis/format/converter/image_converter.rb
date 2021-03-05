# encoding: utf-8

require_relative 'base'
require 'libis/format/identifier'

require 'mini_magick'

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
      class ImageConverter < Libis::Format::Converter::Base

        def self.input_types
          [:TIFF, :JPG, :PNG, :BMP, :GIF, :PDF, :JP2, :PBM, :PGM, :PPM]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:TIFF, :JPG, :PNG, :BMP, :GIF, :PDF, :JP2]
        end

        def self.multipage?(format)
          [:PDF, :TIFF, :GIF, :PBM, :PGM, :PPM].include?(format)
        end

        def initialize
          @wm_image = nil
          super
        end

        def image_convert(_)
          #force usage of this converter
        end

        def quiet(v)
          @quiet = !!v
          self
        end

        def page(nr)
          @page = nr
          self
        end

        def scale(percent)
          @options[:scale] = percent
          self
        end

        def resize(geometry)
          @options[:resize] = geometry
          self
        end

        def quality(value)
          @options[:quality] = value
          self
        end

        def dpi(value)
          @options[:density] = value
          self
        end

        def resample(value)
          @options[:resample] = value
          self
        end

        def flatten(value = true)
          @options[:flatten] = value
          self
        end

        def colorspace(value)
          @options[:colorspace] = value
          self
        end

        def delete_date(value = true)
          @delete_date = value
          self
        end

        def profile(icc)
          @profile = icc
          self
        end

        def convert(source, target, format, opts = {})
          super

          FileUtils.mkpath(File.dirname(target))

          convert_image(source, target, format)

          target

        end

        protected

        def convert_image(source, target, format)

          if @page
            image = MiniMagick::Image.open(source) { |b| b.quiet }
            source = image.pages[@page].path if image.pages.size > 1
          end

          MiniMagick::Tool::Convert.new do |convert|
            convert.quiet if @quiet
            convert << source
            convert.flatten if @options[:flatten].nil? && format == :JPG
            @flags.each {|f, v| v.is_a?(TrueClass) ? convert.send(f).+ : convert.send(f)}
            if @delete_date
              convert << '+set' << 'modify-date' << '+set' << 'create-date'
            end

            colorspace = @options.delete(:colorspace) || 'sRGB'
            unless @options.empty?
              convert.colorspace('RGB')
              @options.each {|o, v| convert.send(o, v.to_s)}
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