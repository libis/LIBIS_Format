# frozen_string_literal: true

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
          new.run source
        end

        def run(source)
          src_file = File.absolute_path(source)

          timeout = Libis::Format::Config[:timeouts][:pdfa_validator]
          result = nil
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
              timeout:,
              kill_after: timeout * 2
            )

            result[:err] << "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]

            Dir.chdir(previous_wd)

            out, err = result[:out].partition { |line| line =~ /^VLD-\[PASS\]/ }
            result[:out] = out
            result[:err] += err

          else
            jar = Libis::Format::Config[:preflight_jar]
            result = Libis::Tools::Command.run(
              Libis::Format::Config[:java_cmd],
              '-jar', jar,
              src_file,
              timeout:,
              kill_after: timeout * 2
            )

            result[:err] << "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]

          end
          result
        end
      end
    end
  end
end
