require 'os'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format

    class PdfCopy
      include ::Libis::Tools::Logger

      def self.run(source, target, options = [])
        self.new.run source, target, options
      end

      def run(source, target, options = [])
        tool_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'tools'))
        jar_file = File.join(tool_dir, 'PdfTool.jar')
        if OS.java?
          # TODO: import library and execute in current VM. For now do exactly as in MRI
          result = Libis::Tools::Command.run(
              Libis::Format::Config[:java_path],
              '-jar', jar_file,
              'CopyPdf',
              '--file_input', source,
              '--file_output', target,
              *options
          )
          warn "PdfCopy errors: #{result[:err].join("\n")}" unless result[:status] == 0
          result[:out]
        else
          result = Libis::Tools::Command.run(
              Libis::Format::Config[:java_path],
              '-jar', jar_file,
              'CopyPdf',
              '--file_input', source,
              '--file_output', target,
              *options
          )
          warn "PdfCopy errors: #{result[:err].join("\n")}" unless result[:status] == 0
          result[:out]
        end
      end
    end

  end
end
