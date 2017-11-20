require 'libis/tools/extend/string'
require 'libis/tools/extend/empty'
require 'libis/tools/command'

require 'csv'
require 'libis/format/config'

module Libis
  module Format
    module Tool

      class FFMpeg
        include Singleton
        include ::Libis::Tools::Logger

        def self.run(source, target, options = {})
          self.instance.run source, target, options
        end

        def run(source, target, options = {})
          opts = []
          opts += options[:global] unless options[:global].empty?
          opts += options[:input] unless options[:input].empty?
          opts << '-i' << source
          opts += options[:filter] unless options[:filter].empty?
          opts += options[:output] unless options[:output].empty?
          opts << target
          result = Libis::Tools::Command.run(Libis::Format::Config[:ffmpeg_path], *opts)

          unless result[:status] == 0
            error "FFMpeg errors: #{(result[:err] + result[:out]).join("\n")}"
            return false
          end
          warn "FFMpeg warnings: #{(result[:err] + result[:out]).join("\n")}" unless result[:err].empty?

          result[:out]
        end

      end

    end
  end
end
