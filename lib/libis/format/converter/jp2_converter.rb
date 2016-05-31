# encoding: utf-8
require 'libis-tools'
require 'fileutils'
require 'libis/format/config'

require_relative 'base'
module Libis
  module Format
    module Converter

      class Jp2Converter < Libis::Format::Converter::Base

        def self.input_types
          [:TIFF, :JPG, :PNG, :BMP, :GIF, :PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)
          [:JP2]
        end

        def initialize
          super
          @options = {
              color_xform: false,
              error_resilience: :ALL,
              lossless: true,
              progression_order: 'RLCP',
              tile_size: [1024, 1024],
              codeblock_size: [6, 6],
          }
        end

        def j2kdriver(_)
          #force usage of this converter
        end

        def color_xform(flag = true)
          @options[:color_xform] = flag
        end

        def error_resilience(value = :ALL)
          @options[:error_resilience] = value
        end

        def lossless(value = true)
          @options[:lossless] = value
        end

        def progression_order(value = 'RLCP')
          @options[:progression_order] = value
        end

        def tile_size(width = 1024, height = 1024)
          @options[:tile_size] = [width, height]
        end

        def codeblock_size(height = 6, width = 6)
          @options[:codeblock_size] = [height, width]
        end

        def convert(source, target, format, opts = {})
          super

          FileUtils.mkpath(File.dirname(target))

          options = []

          @options.each do |key, value|
            case key
              when :color_xform
                options << '--set-output-j2k-color-xform' << (value ? 'YES' : 'NO')
              when :error_resilience
                options << '--set-output-j2k-error-resilience' << value.to_s
              when :lossless
                if value
                  options << '--set-output-j2k-xform' << 'R53' << '5' << '--set-output-j2k-ratio' << '0'
                else
                  options << '--set-output-j2k-xform' << 'I97' << '--set-output-j2k-psnr' << '46'
                end
              when :progression_order
                options << '--set-output-j2k-progression-order' << value.to_s
              when :tile_size
                options << '--set-output-j2k-tile-size' << value[0].to_s << value[1].to_s
              when :codeblock_size
                options << '--set-output-j2k-codeblock-size' << value[0].to_s << value[1].to_s
              else
                #do nothing
            end
          end


          Libis::Tools::Command.run(
              Libis::Format::Config[:j2kdriver],
              '--input-file-name', source,
              '--set-output-type', 'JP2',
              *options,
              '--output-file-name', target,

          )

          target
        end
      end
    end
  end
end
