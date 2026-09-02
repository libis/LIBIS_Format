# frozen_string_literal: true

require_relative 'base'

require 'libis/format/tool/msg_to_pdf'
require 'libis/format/tool/eml_to_pdf'
require 'libis/format/type_database'
require 'rexml/document'

module Libis
  module Format
    module Converter
      class EmailConverter < Libis::Format::Converter::Base
        def self.input_types
          %i[MSG EML]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format)

          %i[PDF]
        end

        def email_convert(_)
          # force usage of this converter
        end

        def convert(source, target, format, opts = {})
          super

          tool = tool_for_format(opts, source)
          tool.run(source, target)
        rescue StandardError => e
          { command: { status: -1 }, errors: [{ error: e.message, error_class: e.class, error_trace: e.backtrace }] }
        end

        private

        def tool_for_format(opts, source)
          if opts[:source_format] == :MSG || File.extname(source).casecmp('.msg').zero?
            Format::Tool::MsgToPdf
          elsif opts[:source_format] == :EML || File.extname(source).casecmp('.eml').zero?
            Format::Tool::EmlToPdf
          else
            raise "Unsupported file extension #{File.extname(source)}"
          end
        end
      end
    end
  end
end
