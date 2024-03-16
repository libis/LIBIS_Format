# frozen_string_literal: true

require 'nokogiri'

require_relative 'base'

require 'libis/format/tool/fop_pdf'

module Libis
  module Format
    module Converter
      class FopPdfConverter < Libis::Format::Converter::Base
        def self.input_types
          [:XML]
        end

        def self.output_types(format = nil)
          return [] if format && !input_types.include?(format)

          [:PDF]
        end

        def convert(source, target, _format, opts = {})
          super

          unless File.file?(source) && File.exist?(source) && File.readable?(source)
            error "File '#{source}' does not exist or is not readable"
            return nil
          end

          FileUtils.mkpath(File.dirname(target))

          Libis::Format::Tool::FopPdf.run(source, target)
        end
      end
    end
  end
end
