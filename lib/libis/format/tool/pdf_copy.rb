# frozen_string_literal: true

require 'os'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format
    module Tool
      class PdfCopy
        include ::Libis::Tools::Logger

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:java_cmd], '-version')
          return false unless (result[:status]).zero?

          File.exist?(Libis::Format::Config[:pdf_tool])
        end

        def self.run(source, target, options = [])
          new.run source, target, options
        end

        def run(source, target, options = [])
          if OS.java?
            # TODO: import library and execute in current VM. For now do exactly as in MRI.
          end

          timeout = Libis::Format::Config[:timeouts][:pdf_copy]
          result = Libis::Tools::Command.run(
            Libis::Format::Config[:java_cmd],
            '-cp', Libis::Format::Config[:pdf_tool],
            'CopyPdf',
            '--file_input', source,
            '--file_output', target,
            *options,
            timeout:,
            kill_after: timeout * 2
          )

          raise "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise "#{self.class} errors: #{result[:err].join("\n")}" unless (result[:status]).zero? && result[:err].empty?

          {
            command: result,
            files: [target]
          }
        end
      end
    end
  end
end
