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

        def self.run(xml, target, options = [])
          self.new.run xml, target, options
        end

        def run(xml, target, options = [])

          if OS.java?
            # TODO: import library and execute in current VM. For now do exactly as in MRI.
          end

          timeout = Libis::Format::Config[:timeouts][:fop]
          result = Libis::Tools::Command.run(
              Libis::Format::Config[:java_cmd],
              "-Dfop.home=#{File.dirname(Libis::Format::Config[:fop_jar])}",
              '-jar', Libis::Format::Config[:fop_jar],
              '-fo', xml,
              '-pdf', target,
              timeout: timeout,
              kill_after: timeout * 2
          )

          raise RuntimeError, "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise RuntimeError, "#{self.class} errors: #{result[:err].join("\n")}" unless result[:status] == 0

        end
      end

    end
  end
end
