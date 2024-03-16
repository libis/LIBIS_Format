# frozen_string_literal: true

require 'os'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format
    module Tool
      class PdfOptimizer
        include ::Libis::Tools::Logger

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:ghostscript_cmd], '--version')
          (result[:status]).zero?
        end

        def self.run(source, target, quality)
          new.run source, target, quality
        end

        def run(source, target, quality)
          timeout = Libis::Format::Config[:timeouts][:pdf_optimizer]
          result = Libis::Tools::Command.run(
            Libis::Format::Config[:ghostscript_cmd],
            '-sDEVICE=pdfwrite',
            '-dCompatibilityLevel=1.4',
            "-dPDFSETTINGS=/#{quality}",
            '-dNOPAUSE',
            '-dBATCH',
            "-sOutputFile=#{target}",
            source.to_s,
            timeout:,
            kill_after: timeout * 2
          )

          raise "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise "#{self.class} errors: #{result[:err].join("\n")}" unless (result[:status]).zero?

          {
            command: result,
            files: [target]
          }
        end
      end
    end
  end
end
