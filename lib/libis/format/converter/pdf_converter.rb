# encoding: utf-8

require_relative 'base'

require 'libis/tools/extend/hash'
require 'libis/format/tool/pdf_copy'
require 'libis/format/tool/pdf_to_pdfa'
require 'libis/format/tool/pdf_optimizer'

module Libis
  module Format
    module Converter

      # noinspection DuplicatedCode
      class PdfConverter < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:PDF, :PDFA]
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

        # Select a partial list of pages
        # @param [String] selection as described in com.itextpdf.text.pdf.SequenceList: [!][o][odd][e][even]start-end
        def range(selection)
          @options[:ranges] = selection.blank? ? nil : selection
        end

        def convert(source, target, format, opts = {})
          super

          result = nil

          unless @options.empty?
            result = convert_pdf(source, target)
            return nil unless result
            source = result
          end

          if format == :PDFA and source
            result = pdf_to_pdfa(source, target)
          end

          result

        end

        OPTIONS_TABLE = {
            title: 'md_title',
            author: 'md_author',
            creator: 'md_creator',
            keywords: 'md_keywords',
            subject: 'md_subject'
        }

        def convert_pdf(source, target)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfCopy.run(
                source, tmpname,
                @options.map {|k, v|
                  if v.nil?
                    nil
                  else
                    k = OPTIONS_TABLE[k] || k
                    ["--#{k}", (v.is_a?(Array) ? v : v.to_s)]
                  end}.compact.flatten
            )
            unless result[:err].empty?
              error("Pdf conversion encountered errors:\n%s", result[:err].join(join("\n")))
              next nil
            end
            tmpname
          end

        end

        def pdf_to_pdfa(source, target)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfToPdfa.run source, tmpname
            if result[:status] != 0
              error("Pdf/A conversion encountered errors:\n%s", result[:err].join("\n"))
              next nil
            else
              warn("Pdf/A conversion warnings:\n%s", result[:err].join("\n")) unless result[:err].empty?
            end
            tmpname
          end

        end

      end

    end
  end
end
