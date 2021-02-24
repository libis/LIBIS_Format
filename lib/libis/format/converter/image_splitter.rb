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

      class ImageSplitter < Libis::Format::Converter::Base

        def self.input_types
          [:PDF, :TIFF, :GIF, :PBM, :PGM, :PPM]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:TIFF, :JPG, :PNG, :BMP, :GIF, :PDF, :JP2]
        end

        def self.multipage?(format)
          [:PDF, :TIFF, :GIF, :PBM, :PGM, :PPM].include?(format)
        end

        def self.category
          :splitter
        end

        def image_split(_)
          #force usage of this converter
        end

        def quiet(v)
          @quiet = !!v
        end

        def convert(source, target, format, opts = {})
          super

          FileUtils.mkpath(File.dirname(target))

          if self.class.multipage?(format)
            target = File.join(File.dirname(target), "#{File.basename(target, '.*')}-%d#{File.extname(target)}")
          end

          result = split_image(source, target, format)
          return nil unless result
          target

        end

        private

        def split_image(source, target, format)

          MiniMagick::Tool::Convert.new do |convert|
            convert.quiet if @quiet
            convert << source
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