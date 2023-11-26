# frozen_string_literal: true

require 'os'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format
    module Tool
      class FopPdf
        include ::Libis::Tools::Logger

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:java_cmd], '-version')
          return false unless (result[:status]).zero?

          File.exist?(Libis::Format::Config[:fop_jar])
        end

        def self.run(xml, target)
          new.run xml, target
        end

        def run(xml, target)
          if OS.java?
            # TODO: import library and execute in current VM. For now do exactly as in MRI.
          end

          timeout = Libis::Format::Config[:timeouts][:fop]
          result = Libis::Tools::Command.run(
            Libis::Format::Config[:java_cmd],
            "-Dfop.home=#{File.dirname(Libis::Format::Config[:fop_jar])}",
            '-Djava.awt.headless=true',
            '-jar', Libis::Format::Config[:fop_jar],
            '-fo', xml,
            '-pdf', target,
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
