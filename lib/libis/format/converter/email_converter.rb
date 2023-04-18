# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/email_to_pdf'
require 'libis/format/type_database'

module Libis
  module Format
    module Converter

      class EmailConverter < Libis::Format::Converter::Base

        def self.input_types
          [ :MSG ]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)
          [ :PDF ]
        end

        def email_convert(_)
          #force usage of this converter
        end

        def convert(source, target, format, opts = {})
          super

          return nil unless Format::Tool::EmailToPdf.run(source, target)

          target

        end

      end

    end
  end
end
