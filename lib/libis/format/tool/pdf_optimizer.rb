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

          Libis::Tools::Command.run(
              'gs',
              '-sDEVICE=pdfwrite',
              '-dCompatibilityLevel=1.4',
              "-dPDFSETTINGS=/#{quality}",
              '-dNOPAUSE',
              '-dBATCH',
              "-sOutputFile=#{target}",
              "#{source}"
          )

        end
      end

    end
  end
end
