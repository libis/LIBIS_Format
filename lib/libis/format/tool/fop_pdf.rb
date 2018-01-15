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

          Libis::Tools::Command.run(
              Libis::Format::Config[:java_path],
              "-Dfop.home=#{File.dirname(Libis::Format::Config[:fop_jar])}",
              '-jar', Libis::Format::Config[:fop_jar],
              '-fo', xml,
              '-pdf', target
          )

        end
      end

    end
  end
end
