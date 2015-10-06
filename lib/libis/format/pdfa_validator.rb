require 'fileutils'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format

    class PdfaValidator
      include ::Libis::Tools::Logger

      def self.run(source)
        self.new.run source
      end

      def run(source)

        src_file = File.absolute_path(source)

        if (pdfa = Libis::Format::Config[:pdfa_path])
          # Keep it clean: tool generates fontconfig/ cache dir in current working dir
          previous_wd = Dir.getwd
          Dir.chdir(Dir.tmpdir)

          result = Libis::Tools::Command.run(
              pdfa,
              '--noxml',
              '--level', 'B',
              '--verb', '0',
              src_file
          )

          Dir.chdir(previous_wd)

          unless result[:out].any? { |line| line =~ /^VLD-\[PASS\]/ }
            warn "Validator failed to validate the PDF file '%s' against PDF/A-1B constraints:\n%s", source,
                 result[:out].join("\n")
            return false
          end
        else
          jar = File.join(ROOT_DIR, 'tools', 'pdfbox', 'preflight-app-1.8.10.jar')
          result = Libis::Tools::Command.run(
              Libis::Format::Config[:java_path],
              '-jar', jar,
              src_file
          )
          unless result[:status] == 0
            warn "Validator failed to validate the PDF file '%s' against PDF/A-1B constraints:\n%s", source,
                 result[:err].join("\n")
            return false
          end
        end
        true
      end
    end

  end
end
