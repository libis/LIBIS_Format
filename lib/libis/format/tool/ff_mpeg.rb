# frozen_string_literal: true

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

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:ffmpeg_cmd], '-h')
          (result[:status]).zero?
        end

        def self.run(source, target, options = {})
          instance.run source, target, options
        end

        def run(source, target, options = {})
          opts = []
          opts += options[:global] unless options[:global].empty?
          opts += options[:input] unless options[:input].empty?
          opts << '-i' << source
          opts += options[:filter] unless options[:filter].empty?
          opts += options[:output] unless options[:output].empty?
          opts << target

          timeout = Libis::Format::Config[:timeouts][:ffmpeg]
          result = Libis::Tools::Command.run(
            Libis::Format::Config[:ffmpeg_cmd], *opts,
            timeout:,
            kill_after: timeout * 2
          )

          raise "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise "#{self.class} errors: #{result[:err].join("\n")}" unless (result[:status]).zero?

          warn "FFMpeg warnings: #{(result[:err] + result[:out]).join("\n")}" unless result[:err].empty?

          {
            command: result,
            files: [target]
          }
        end
      end
    end
  end
end
