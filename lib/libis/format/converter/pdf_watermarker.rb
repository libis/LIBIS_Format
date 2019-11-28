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
          return [] unless input_types.include?(format) if format
          [:PDF]
        end

        def pdf_watermark(_)
          #force usage of this converter
        end

        def initialize
          super
          @options[:text] = '© LIBIS'
          @options[:opacity] = '0.3'
        end

        def file(v)
          @options[:file] = v.blank? ? nil : v
        end

        def text(v)
          @options[:text] = v
        end

        def rotation(v)
          @options[:rotation] = v unless v.blank?
        end

        def size(v)
          @options[:size] = v unless v.blank?
        end

        def opacity(v)
          @options[:opacity] = v unless v.blank?
        end

        def gap_size(v)
          @options[:gap_size] = v
        end

        def gap_ratio(v)
          @options[:gap_ratio] = v
        end

        def convert(source, target, format, opts = {})
          super

          result = convert_pdf(source, target)
          return nil unless result

          result

        end

        OPTIONS_TABLE = {
            file: 'wm_image',
            text: 'wm_text',
            rotation: 'wm_text_rotation',
            size: 'wm_font_size',
            opacity: 'wm_opacity',
            gap_size: 'wm_gap_size',
            gap_ratio: 'wm_gap_ratio'
        }
        # noinspection DuplicatedCode
        def convert_pdf(source, target)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfCopy.run(
                source, tmpname,
                @options.map {|k, v|
                  if v.nil?
                    nil
                  else
                    v = v.split('\n') unless v.blank? if k == :text
                    k = OPTIONS_TABLE[k] || k
                    ["--#{k}", (v.is_a?(Array) ? v : v.to_s)]
                  end}.compact.flatten
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
