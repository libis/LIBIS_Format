# encoding: utf-8

require_relative 'base'

require 'libis/format/office_to_pdf'
require 'libis/format/type_database'

module Libis
  module Format
    module Converter

      class OfficeConverter < Libis::Format::Converter::Base

        def self.input_types(_ = nil)
          [
              :TXT,
              :RTF,
              :HTML,
              :MSDOC,
              :MSXLS,
              :MSPPT,
              :MSDOCX,
              :MSXLSX,
              :MSPPTX,
              :WORDPERFECT,
          ]
        end

        def self.output_types(_ = nil)
          [:PDF]
        end

        def office_convert(_)
          #force usage of this converter
        end

        def convert(source, target, format, opts = {})
          super

          return nil unless OfficeToPdf.run(source, target)

          target

        end

      end

    end
  end
end
