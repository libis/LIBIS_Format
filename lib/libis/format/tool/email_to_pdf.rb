require 'fileutils'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/config'

module Libis
  module Format
    module Tool

      class EmailToPdf
        include ::Libis::Tools::Logger

        def self.run(source, target, options = {})
          self.new.run source, target, options
        end

        def run(source, target, _ = {})
          timeout = Libis::Format::Config[:timeouts][:email2pdf] || 120
          result = Libis::Tools::Command.run(
              Libis::Format::Config[:email2pdf_cmd],
              source,
              target,
              timeout: timeout,
              kill_after: timeout * 2
          )

          raise RuntimeError, "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          warn "EmailToPdf conversion messages: \n\t#{result[:out].join("\n\t")}" unless result[:err].empty?
          raise RuntimeError, "#{self.class} failed to generate target file #{target}" unless File.exist?(target)

          nil
        end
      end

    end
  end
end
