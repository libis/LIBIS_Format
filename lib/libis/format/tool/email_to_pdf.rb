require 'fileutils'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'
require 'rexml/document'

module Libis
  module Format
    module Tool

      class EmailToPdf
        include ::Libis::Tools::Logger

        def self.run(source, target, options = {})
          self.new.run source, target, options
        end

        def run(source, target, _ = {})
          timeout = Libis::Format::Config[:timeouts][:email2pdf] || 120
          result = Libis::Tools::Command.run(
              Libis::Format::Config[:email2pdf_cmd],
              source,
              target,
              timeout: timeout,
              kill_after: timeout * 2
          )

          warn "EmailToPdf conversion messages: \n\t#{result[:out].join("\n\t")}" unless result[:out].empty?

          raise RuntimeError, "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise RuntimeError, "#{self.class} failed to generate target file #{target}" unless File.exist?(target)
          raise RuntimeError, "#{self.class} command failed with status code #{result[:status]}" unless result[:status] == 0

          base_path = File.join(File.dirname(target), File.basename(target, '.*'))
          headers = read_header("#{base_path}.headers.xml")

          {
            command: result,
            files: [ target ] << headers[:attachments].map {|a| File.join("#{base_path}-attachments", a)},
            headers: headers
          }

        end

        private

        def read_header(header_file)
          headers = {}
          return headers unless File.exist?(header_file)
          doc = REXML::Document.new(File.new(header_file))
          root = doc.root
          root.elements('/emailheader/*').each do |element|
            case(element.name)
            when 'attachments'
              headers[:attachments] = element.elements.map {|e| e.text }
            else
              headers[element.name.to_sym] = element.text
            end
          end
          headers
        end
      end

    end
  end
end
