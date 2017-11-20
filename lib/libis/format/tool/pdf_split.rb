require 'os'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format
    module Tool

      class PdfSplit
        include ::Libis::Tools::Logger

        def self.run(source, target, options = [])
          self.new.run source, target, options
        end

        def run(source, target, options = [])
          tool_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'tools'))
          jar_file = File.join(tool_dir, 'PdfTool.jar')
          if OS.java?
            # TODO: import library and execute in current VM. For now do exactly as in MRI.
          end

          Libis::Tools::Command.run(
              Libis::Format::Config[:java_path],
              '-cp', jar_file,
              'SplitPdf',
              '--file_input', source,
              '--file_output', target,
              *options
          )

        end
      end

    end
  end
end
