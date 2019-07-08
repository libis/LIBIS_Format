# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/spreadsheet_to_ods'
require 'libis/format/library'

module Libis
  module Format
    module Converter

      class SpreadsheetConverter < Libis::Format::Converter::Base

        def self.input_types
          [
              :MSXLS,
              :MSXLSX,
              :OO_CALC
          ]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)
          [:OO_CALC]
        end

        def spreadsheet_convert(_)
          #force usage of this converter
        end

        def convert(source, target, format, opts = {})
          super

          return nil unless Format::Tool::SpreadsheetToOds.run(source, target)

          target

        end

      end

    end
  end
end
