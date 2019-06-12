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

      # noinspection RubyTooManyInstanceVariablesInspection,DuplicatedCode
      class ImageAssembler < Libis::Format::Converter::Base

        def self.input_types
          [:TIFF, :JPG, :PNG, :BMP, :GIF, :PDF, :JP2]
        end

        def self.output_types(format = nil)
          [:PDF, :TIFF, :GIF, :PBM, :PGM, :PPM]
        end

        def self.category
          :assembler
        end

        def image_assemble(_)
          #force usage of this converter
        end

        def quiet(v)
          @quiet = !!v
        end

        def convert(source, target, format, opts = {})
          super

          FileUtils.mkpath(File.dirname(target))

          if source.is_a? Array
            assemble(source, target, format)
          elsif File.directory?(source)
            source_list = Dir[File.join(source, '**', '*')].reject {|p| File.directory? p}
            assemble(source_list, target, format)
          else
            image = MiniMagick::Image.open(source) {|b| b.quiet}
            if image.pages.size > 1
              assemble(image.pages.map {|page| page.path}, target, format)
            else
              assemble([source], target, format)
            end
          end

          target

        end

        private

        def assemble(sources, target, format)
          MiniMagick::Tool::Convert.new do |b|
            sources.each {|source| b << source}
            convert.format(format)
            b << target
          end
        end

      end

    end
  end
end
