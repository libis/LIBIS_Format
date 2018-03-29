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

        def self.run(source, target, quality)
          self.new.run source, target, quality
        end

        def run(source, target, quality)

          timeout = Libis::Format::Config[:timeouts][:pdf_optimizer]
          result = Libis::Tools::Command.run(
              'gs',
              '-sDEVICE=pdfwrite',
              '-dCompatibilityLevel=1.4',
              "-dPDFSETTINGS=/#{quality}",
              '-dNOPAUSE',
              '-dBATCH',
              "-sOutputFile=#{target}",
              "#{source}",
              timeout: timeout,
              kill_after: timeout * 2
          )

          raise RuntimeError, "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise RuntimeError, "#{self.class} errors: #{result[:err].join("\n")}" unless result[:status] == 0 && result[:err].empty?

          result
        end
      end

    end
  end
end
