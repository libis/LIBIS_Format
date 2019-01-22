require 'awesome_print'
require 'libis-format'
require 'libis-tools'

require_relative 'sub_command'

module Libis
  module Format
    module Cli
      class Format < SubCommand

        no_commands do
          def self.description(field)
            "#{STRING_CONFIG[field]}." + (DEFAULT_CONFIG[field].nil? ? '' : " default: #{DEFAULT_CONFIG[field]}")
          end
        end

        DEFAULT_CONFIG = {
            droid: true,
            fido: true,
            file: true,
            xml_validation: true
        }

        STRING_CONFIG = {
            droid: 'Use Droid to identify the format',
            fido: 'Use Fido to identify the format',
            file: 'Use File to identify the format',
            xml_validation: 'When XML file found, validate the file against known XML schemas',
        }

        desc 'identify FILE [options]', 'Identify the FILE using a combination of the tools.'
        long_desc <<-DESC
  
        'identify FILE [options]' will idnetify a file using a combination of tools.

        The file will be identified by each of the selected tools in turn and the format with best score will be
        selected to give the final result. The score is determined by the identification method and will be lowered if
        a known weak format (e.g. zip file) is detected.

        The tool will display as much information about the format as possible, including the format candidates that
        were not selected.

        DESC

        method_option :droid, default: DEFAULT_CONFIG[:droid], type: :boolean, desc: STRING_CONFIG[:droid]
        method_option :fido, default: DEFAULT_CONFIG[:fido], type: :boolean, desc: STRING_CONFIG[:fido]
        method_option :file, default: DEFAULT_CONFIG[:file], type: :boolean, desc: STRING_CONFIG[:file]
        method_option :xml_validation, default: DEFAULT_CONFIG[:xml_validation], type: :boolean, desc: STRING_CONFIG[:xml_validation]

        def identify(source_file)
          ::Libis::Tools::Config.logger.level = :WARN
          opts = options.inject({}) { |h, x| h[x.first.to_sym] = x.last; h}
          opts[:keep_output] = true
          result = ::Libis::Format::Identifier.get source_file, opts
          puts '--- messages ---'
          result[:messages].each do |message|
            puts "#{message[0]} : #{message[1]}"
          end

          puts '--- formats ---'
          result[:formats].each do |file, info|
            puts "#{file}:"
            ap info
          end

          puts '--- tool results ---'
          result[:output].each do |file, info|
            puts "#{file}:"
            ap info
          end
        end

      end
    end
  end
end