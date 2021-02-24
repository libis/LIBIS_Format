# encoding: utf-8
require 'securerandom'

require_relative 'base'
require 'libis/format/tool/pdf_protect'

module Libis
  module Format
    module Converter

      RANDOM_CHARS = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten

      # noinspection DuplicatedCode
      class PdfProtecter < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          return [] unless input_types.include?(format) if format
          [:PDF, :PDFA]
        end

        def pdf_protect(_)
          #force usage of this converter
        end

        def initialize
          super
          @options[:edit_password] = SecureRandom.urlsafe_base64(31)
        end

        def edit_password(pwd)
          @options[:edit_password] = pwd
        end

        def open_password(pwd)
          @options[:open_password] = pwd
        end

        def assist(v)
          @flags[:assist] = !!v
        end

        def copy(v)
          @flags[:copy] = !!v
        end

        def print(v)
          @flags[:print] = !!v
        end

        def comments(v)
          @flags[:comments] = !!v
        end

        def fillin(v)
          @flags[:fillin] = !!v
        end

        def manage(v)
          @flags[:manage] = !!v
        end

        def edit(v)
          @flags[:edit] = !!v
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
          edit_password: 'edit-password',
          open_password: 'open-password',
          fillin: 'fill-in',
        }

        def convert_pdf(source, target)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfProtect.run(
              source, tmpname,
              [
                @options.map { |k, v|
                  if v.nil?
                    nil
                  else
                    k = OPTIONS_TABLE[k] || k
                    ["--#{k}", v]
                  end
                },
                @flags.map { |k, v|
                  if !v
                    nil
                  else
                    k = OPTIONS_TABLE[k] || k
                    "--#{k}"
                  end
                }
              ].compact.flatten
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
