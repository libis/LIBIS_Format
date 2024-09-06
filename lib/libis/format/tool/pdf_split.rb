# frozen_string_literal: true

require 'libis/format/tool/pdf_tool'

module Libis
  module Format
    module Tool
      class PdfSplit

        def self.run(source, target, *options)
          PdfTool.run('split', source, target, *options)
        end

        def run(source, target, *options)
          PdfTool.run('split', source, target, *options)
        end
      end
    end
  end
end
