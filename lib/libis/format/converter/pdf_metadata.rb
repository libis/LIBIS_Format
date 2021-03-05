# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/pdf_metadata'

module Libis
  module Format
    module Converter

      # noinspection DuplicatedCode
      class PdfMetadata < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:PDF]
        end

        def title(v)
          @options[:title] = v.blank? ? nil : v
        end

        def author(v)
          @options[:author] = v.blank? ? nil : v
        end

        def creator(v)
          @options[:creator] = v.blank? ? nil : v
        end

        def keywords(v)
          @options[:keywords] = v.blank? ? nil : v
        end

        def subject(v)
          @options[:subject] = v.blank? ? nil : v
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
            result = Libis::Format::Tool::PdfMetadata.run(
                source, tmpname,
                @options.map {|k, v|
                  if v.nil?
                    nil
                  else
                    ["--#{k}", v.to_s]
                  end}.compact.flatten
            )
            unless result[:err].empty?
              error("Pdf conversion encountered errors:\n%s", result[:err].join(join("\n")))
              next nil
            end
            tmpname
          end

        end

      end

    end
  end
end
