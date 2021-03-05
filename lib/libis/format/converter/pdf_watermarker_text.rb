# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/pdf_watermark'

module Libis
  module Format
    module Converter

      class PdfWatermarkerText < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:PDF]
        end

        def pdf_watermark_text(_)
          #force usage of this converter
        end

        def initialize
          super
          @text = []
          @options[:opacity] = '0.3'
        end

        def text(v)
          @text += v.split("\n")
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

        def gap(v)
          @options[:gap] = v
        end

        def padding(v)
          @options[:padding] = v
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
            result = Libis::Format::Tool::PdfWatermark.run(
                source, tmpname, 'text',
                @options.map {|k, v|
                  if v.nil?
                    nil
                  else
                    ["--#{k}", v.to_s]
                  end
                  }.compact.flatten + @text
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
