require "fileutils"

require "libis/tools/extend/string"
require "libis/tools/logger"
require "libis/tools/command"

require "libis/format/config"
require "rexml/document"

module Libis
  module Format
    module Tool
      class EmailToPdf
        include ::Libis::Tools::Logger

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:email2pdf_cmd], "-v")
          result[:status] == 0
        end

        def self.run(source, target, options = {})
          new.run source, target, options
        end

        def run(source, target, _ = {})
          timeout = Libis::Format::Config[:timeouts][:email2pdf] || 120
          result = Libis::Tools::Command.run(
            Libis::Format::Config[:java_cmd],
            "-Duser.timezone=Europe/Brussels -Duser.language=nl -Duser.country=BE",
            "jar", Libis::Format::Config[:email2pdf_cmd],
            "-e", "-hd", "-a",
            "-o", target,
            source,
            timeout: timeout,
            kill_after: timeout * 2
          )

          warn "EmailToPdf conversion messages: \n\t#{result[:out].join("\n\t")}" unless result[:out].empty?

          raise "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise "#{self.class} failed to generate target file #{target}" unless File.exist?(target)
          raise "#{self.class} command failed with status code #{result[:status]}" unless result[:status] == 0

          base_path = File.join(File.dirname(target), File.basename(target, ".*"))
          headers_file = "#{base_path}.headers.xml"
          headers = read_header(headers_file)

          {
            command: result,
            files: [target, headers_file] + headers[:attachments].map { |a| File.join("#{base_path}-attachments", a) },
            headers: headers
          }
        end

        private

        def read_header(headers_file)
          headers = {}
          return headers unless File.exist?(headers_file)
          doc = REXML::Document.new(File.new(headers_file))
          root = doc.root
          root.elements("/emailheader/*").each do |element|
            case element.name
            when "attachments"
              headers[:attachments] = element.elements.map { |e| e.text }
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
