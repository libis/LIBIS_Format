# frozen_string_literal: true

require 'libis/tools/extend/string'
require 'libis/tools/command'

require 'csv'
require 'libis/format/config'

require_relative 'identification_tool'

module Libis
  module Format
    module Tool
      class Fido < Libis::Format::Tool::IdentificationTool
        def self.add_formats(formats_file)
          instance.formats << formats_file unless instance.formats.include?(formats_file)
        end

        def self.del_formats(formats_file)
          instance.formats.delete(formats_file)
        end

        attr_reader :formats

        def run_list(filelist, **options)
          create_list_file(filelist) do |list_file|
            output = runner(nil, '-input', list_file.escape_for_string, **options)
            process_output(output)
          end
        end

        def run_dir(dir, recursive = true, **options)
          args = []
          args << '-recurse' if recursive
          output = runner(dir, *args, **options)
          process_output(output)
        end

        def run(file, **options)
          output = runner(file, **options)
          process_output(output)
        end

        protected

        def initialize
          super
          @formats = Libis::Format::Config[:fido_formats].dup
          bad_mimetype('application/vnd.oasis.opendocument.text')
          bad_mimetype('application/vnd.oasis.opendocument.spreadsheet')
        end

        attr_writer :formats

        def runner(filename, *args, **options)
          # Load custom format definitions if present
          args << '-loadformats' << formats.join(',').to_s unless formats.empty?

          # Workaround for Fido performance bug
          args << '-bufsize' << (options[:bufsize] || 1000).to_s

          # Other options
          args << '-container_bufsize' << options[:container_bufsize].to_s if options[:container_bufsize]
          args << '-pronom_only' if options[:pronom_only]
          args << '-nocontainer' if options[:nocontainer]

          # Add filename to argument list (optional)
          args << filename.escape_for_string.to_s if filename

          # No header output
          args << '-q'

          # Run command and capture results
          timeout = Libis::Format::Config[:timeouts][:fido]
          result = ::Libis::Tools::Command.run(
            Libis::Format::Config[:fido_cmd], *args,
            timeout:,
            kill_after: timeout * 2
          )

          # Log warning if needed
          raise "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]
          raise "#{self.class} errors: #{result[:err].join("\n")}" unless (result[:status]).zero? && result[:err].empty?

          # Parse output (CSV) text into array and return result
          keys = %i[status time puid format_name format_version filesize filepath mimetype matchtype]
          data = CSV.parse(result[:out].join("\n"))
                    .map { |a| Hash[keys.zip(a)] }
                    .select { |a| a[:status] == 'OK' }
          data.each do |r|
            r.delete(:time)
            r.delete(:status)
            r.delete(:filesize)
            r[:tool] = :fido
          end
        end
      end
    end
  end
end
