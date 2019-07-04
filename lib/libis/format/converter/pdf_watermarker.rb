# encoding: utf-8

require_relative 'base'

require 'libis/tools/extend/hash'
require 'libis/format/tool/pdf_copy'
require 'libis/format/tool/pdf_to_pdfa'
require 'libis/format/tool/pdf_optimizer'

module Libis
  module Format
    module Converter

      class PdfWatermarker < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)
          [:PDF]
        end

        def pdf_watermark(_)
          #force usage of this converter
        end

        def initialize
          super
          @options['wm_text'] = '© LIBIS'
          @options['wm_opacity'] = '0.3'
        end

        def file(v)
          @options['wm_image'] = v.blank? ? nil : v
        end

        def text(v)
          @options['wm_text'] = v.split('\n') unless v.blank?
        end

        def rotation(v)
          @options['wm_text_rotation'] = v unless v.blank?
        end

        def size(v)
          @options['wm_font_size'] = v unless v.blank?
        end

        def opacity(v)
          @options['wm_opacity'] = v unless v.blank?
        end

        def gap(v)
          case v.to_s
          when /^\s*(0+\.\d+|1\.0+)\s*$/
            @options['wm_gap_ratio'] = v
          when /^\s*\d+\s*$/
            @options['wm_gap_size'] = v
          else

          end
        end

        def convert(source, target, format, opts = {})
          super

          result = convert_pdf(source, target)
          return nil unless result

          result

        end

        # noinspection DuplicatedCode
        def convert_pdf(source, target)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfCopy.run(
                source, tmpname,
                @options.map {|k, v|
                  if v.nil?
                    nil
                  else
                    ["--#{k}", (v.is_a?(Array) ? v : v.to_s)]
                  end}.flatten
            )
            unless result[:err].empty?
              error("Pdf conversion encountered errors:\n%s", result[:err].join(join("\n")))
              next nil
            end
            tmpname
          end

        end

      end

    end
  end
end
