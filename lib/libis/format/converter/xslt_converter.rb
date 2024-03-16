# frozen_string_literal: true

require_relative 'base'

module Libis
  module Format
    module Converter
      class XsltConverter < Libis::Format::Converter::Base
        def self.input_types
          [:XML]
        end

        def self.output_types(format = nil)
          return [] if format && !input_types.include?(format)

          %i[XML HTML TXT]
        end

        def xsl_file(file_path)
          @options[:xsl_file] = file_path
        end

        def convert(source, target, _format, opts = {})
          super

          unless File.file?(source) && File.exist?(source) && File.readable?(source)
            error "File '#{source}' does not exist or is not readable"
            return nil
          end

          unless @options[:xsl_file]
            error 'No xsl_file supplied'
            return nil
          end

          FileUtils.mkpath(File.dirname(target))

          if RUBY_PLATFORM == 'java'
            require 'saxon-xslt'
            xsl = Saxon.XSLT(File.open(@options[:xsl_file]))
            xml = Saxon.XML(File.open(source))
            result = xsl.transform(xml)
            File.write(target, result.to_s)
          else
            require 'nokogiri'

            doc = nil
            begin
              doc = Nokogiri::XML(File.read(source)) do |config|
                config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS
              end
            rescue Nokogiri::XML::SyntaxError => e
              if e.fatal? || e.error?
                error "Error parsing XML input '#{source}': #{e.messsage} @ #{e.backtrace[0]}"
                return nil
              end
            end

            file = @options[:xsl_file]

            unless File.file?(file) && File.exist?(file) && File.readable?(file)
              error "XSL file '#{@options[:xsl_file]}' does not exist or is not readable"
              return nil
            end

            xsl = nil

            begin
              fp = File.open(file, 'r')
              xsl = Nokogiri::XSLT(fp) do |config|
                config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS
              end
            rescue Nokogiri::XML::SyntaxError => e
              if e.fatal? || e.error?
                error "Error parsing XSL input '#{file}': #{e.message} @ #{e.backtrace[0]}"
                return nil
              end
            ensure
              fp.close
            end

            begin
              target_xml = xsl.transform(doc)
              fp = File.open(target, 'w')
              fp.write(target_xml)
            rescue Exception => e
              error "Error transforming '#{source}' with '#{file}': #{e.message} @ #{e.backtrace[0]}"
              return nil
            ensure
              fp.close unless fp.nil? || fp.closed?
            end

            {
              command: { status: 0 },
              files: [target]
            }

          end
        end
      end
    end
  end
end
