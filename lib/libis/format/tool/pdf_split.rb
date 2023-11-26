# frozen_string_literal: true

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

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:java_cmd], '-version')
          return false unless (result[:status]).zero?

          File.exist?(Libis::Format::Config[:pdf_tool])
        end

        def self.run(source, target, *args)
          new.run source, target, *args
        end

        def run(source, target, *args)
          if OS.java?
            # TODO: import library and execute in current VM. For now do exactly as in MRI.
          end

          timeout = Libis::Format::Config[:timeouts][:pdf_split]
          result = Libis::Tools::Command.run(
            Libis::Format::Config[:java_cmd],
            '-cp', Libis::Format::Config[:pdf_tool],
            'SplitPdf',
            '--file_input', source,
            '--file_output', target,
            *args,
            timeout:,
            kill_after: timeout * 2
          )

          raise "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise "#{self.class} errors: #{result[:err].join("\n")}" unless (result[:status]).zero? && result[:err].empty?

          {
            command: result,
            files: [target] # TODO: collect the files
          }
        end
      end
    end
  end
end
