# frozen_string_literal: true

require_relative 'base'

require 'libis/format/tool/msg_to_pdf'
require 'libis/format/type_database'
require 'rexml/document'

module Libis
  module Format
    module Converter
      class EmailConverter < Libis::Format::Converter::Base
        def self.input_types
          [:MSG]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)

          [:PDF]
        end

        def email_convert(_)
          # force usage of this converter
        end

        def convert(source, target, format, opts = {})
          super

          Format::Tool::MsgToPdf.run(source, target)
        end
      end
    end
  end
end
