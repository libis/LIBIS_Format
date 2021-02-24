# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/pdf_metadata'

module Libis
  module Format
    module Converter

      # noinspection DuplicatedCode
      class PdfConverter < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:PDFA]
        end

        def convert(source, target, format, opts = {})
          super

          result = pdf_to_pdfa(source, target)
          return nil unless result

          result

        end

        def pdf_to_pdfa(source, target)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfToPdfa.run source, tmpname
            if result[:status] != 0
              error("Pdf/A conversion encountered errors:\n%s", result[:err].join("\n"))
              next nil
            else
              warn("Pdf/A conversion warnings:\n%s", result[:err].join("\n")) unless result[:err].empty?
            end
            tmpname
          end

        end

      end

    end
  end
end
