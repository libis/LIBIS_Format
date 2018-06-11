# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/office_to_pdf'
require 'libis/format/type_database'

module Libis
  module Format
    module Converter

      class OfficeConverter < Libis::Format::Converter::Base

        def self.input_types
          [
              :TXT,
              :RTF,
              :HTML,
              :MSDOC,
              :MSDOT,
              :MSXLS,
              :MSPPT,
              :MSDOCX,
              :MSDOTX,
              :MSXLSX,
              :MSPPTX,
              :WORDPERFECT,
              :OO_WRITER,
              :OO_IMPRESS,
              :OO_CALC
          ]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)
          [:PDF]
        end

        def office_convert(_)
          #force usage of this converter
        end

        def convert(source, target, format, opts = {})
          super

          return nil unless Format::Tool::OfficeToPdf.run(source, target)

          target

        end

      end

    end
  end
end
