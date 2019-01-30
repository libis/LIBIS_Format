require 'fileutils'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format
    module Tool

      class PdfaValidator
        include ::Libis::Tools::Logger

        def self.run(source)
          self.new.run source
        end

        def run(source)

          src_file = File.absolute_path(source)

          timeout = Libis::Format::Config[:timeouts][:pdfa_validator]
          if (pdfa = Libis::Format::Config[:pdfa_cmd])
            # Keep it clean: tool generates fontconfig/ cache dir in current working dir
            previous_wd = Dir.getwd
            Dir.chdir(Dir.tmpdir)

            result = Libis::Tools::Command.run(
                pdfa,
                '--noxml',
                '--level', 'B',
                '--verb', '0',
                src_file,
                timeout: timeout,
                kill_after: timeout * 2
            )

            raise RuntimeError, "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
            raise RuntimeError, "#{self.class} errors: #{result[:err].join("\n")}" unless result[:status] == 0 && result[:err].empty?

            Dir.chdir(previous_wd)

            unless result[:out].any? {|line| line =~ /^VLD-\[PASS\]/}
              warn "Validator failed to validate the PDF file '%s' against PDF/A-1B constraints:\n%s", source,
                   result[:out].join("\n")
              return false
            end
          else
            jar = Libis::Format::Config[:preflight_jar]
            result = Libis::Tools::Command.run(
                Libis::Format::Config[:java_cmd],
                '-jar', jar,
                src_file,
                timeout: timeout,
                kill_after: timeout * 2
            )
            raise RuntimeError, "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]

            unless result[:status] == 0
              warn "Validator failed to validate the PDF file '%s' against PDF/A-1B constraints:\n%s", source,
                   result[:out].join("\n")
              return false
            end
          end
          true
        end
      end

    end
  end
end
