# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/pdf_select'

module Libis
  module Format
    module Converter

      # noinspection DuplicatedCode
      class PdfSelecter < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:PDF]
        end

        def pdf_select(_)
          #force usage of this converter
        end

        def initialize
          super
          @options[:ranges] = []
        end

        # Select a partial list of pages
        # @param [String] selection as described in com.itextpdf.text.pdf.SequenceList: [!][o][odd][e][even]start-end
        def range(selection)
          @options[:ranges] += selection.split(/\s*,\s*/) unless selection.blank?
        end

        # Select a partial list of pages
        # @param [String|Array<String>] selection as described in com.itextpdf.text.pdf.SequenceList: [!][o][odd][e][even]start-end
        def ranges(selection)
          case selection
          when Array
            @options[:ranges] += selection.to_s unless selection.empty?
          when String
            range([selection])
          else
            # nothing
          end
        end

        def convert(source, target, format, opts = {})
          super

          result = nil

          unless @options.empty?
            result = convert_pdf(source, target)
            return nil unless result
          end

          result

        end

        def convert_pdf(source, target)

          using_temp(target) do |tmpname|
            opts = @options[:ranges].map { |range| ["-r", range] }.compact.flatten
            result = Libis::Format::Tool::PdfSelect.run(source, tmpname, opts)
            unless result[:err].empty?
              error("Pdf selection encountered errors:\n%s", result[:err].join(join("\n")))
              next nil
            end
            tmpname
          end

        end

      end

    end
  end
end
