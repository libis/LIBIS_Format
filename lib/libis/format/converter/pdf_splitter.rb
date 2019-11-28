# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/pdf_split'

module Libis
  module Format
    module Converter

      # noinspection DuplicatedCode
      class PdfSplitter < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:PDF]
        end

        def pdf_split(_)
          #force usage of this converter
        end

        def self.category
          :splitter
        end

        # Split at given page. If omitted or nil, the source PDF will be split at every page
        def page(v)
          @page = v unless v.blank
        end

        def convert(source, target, format, opts = {})
          super

          result = split(source, target)
          return nil unless result

          result
        end

        private

        def split(source, target)

          options = @page ? ['--page', @page] : ['--every_page']
          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfSplit.run(source, tmpname, *options)
            unless result[:err].empty?
              error("Pdf split encountered errors:\n%s", result[:err].join(join("\n")))
              next nil
            end
            tmpname
          end

        end

      end

    end
  end
end
