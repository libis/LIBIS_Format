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
          args = [
            Libis::Format::Config[:ghostscript_cmd],
            '-sDEVICE=pdfwrite',
            '-dCompatibilityLevel=1.4',
            "-dPDFSETTINGS=/#{quality}",
            '-dNOPAUSE',
            '-dBATCH',
            "-sOutputFile=#{target}",
            source.to_s
          ]

          result = Libis::Tools::Command.run(*args, timeout:, kill_after: timeout * 2)

          result[:err] << "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]

          result
        end
      end
    end
  end
end
