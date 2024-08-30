# frozen_string_literal: true

require 'os'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format
    module Tool
      class PdfTool
        include ::Libis::Tools::Logger

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:java_cmd], '-version')
          return false unless (result[:status]).zero?

          File.exist?(Libis::Format::Config[:pdf_tool])
        end

        def self.run(command, source, target, *options)
          new.run command, source, target, *options
        end

        def run(command, source, target, *options)
          if OS.java?
            # TODO: import library and execute in current VM. For now do exactly as in MRI.
          end

          timeout = Libis::Format::Config[:timeouts][:pdf_tool]
          args = [
            Libis::Format::Config[:java_cmd],
            '-jar', Libis::Format::Config[:pdf_tool],
            [command],
            '-i', source,
            '-o', target,
            options,
          ].flatten

          result = Libis::Tools::Command.run(*args, timeout: , kill_after: timeout * 2)

          result[:err] << "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]

          result
        end
      end
    end
  end
end
