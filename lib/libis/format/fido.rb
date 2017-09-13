require 'libis/tools/extend/string'
require 'libis/tools/command'

require 'csv'
require 'libis/format/config'

require_relative 'identification_tool'

module Libis
  module Format

    class Fido < Libis::Format::IdentificationTool

      def self.add_formats(formats_file)
        self.instance.formats << formats_file unless self.instance.formats.include?(formats_file)
      end

      def self.del_formats(formats_file)
        self.instance.formats.delete(formats_file)
      end

      attr_reader :formats

      protected

      def initialize
        @formats = Libis::Format::Config[:fido_formats].dup
        bad_mimetype('application/vnd.oasis.opendocument.text')
        bad_mimetype('application/vnd.oasis.opendocument.spreadsheet')
      end

      attr_writer :formats

      def run_list(filelist)
        create_list_file(filelist) do |list_file|
          output = runner(nil, '-input', list_file.escape_for_string)
          process_output(output)
        end
      end

      def run_dir(dir, recursive = true)
        args = []
        args << '-recursive' if recursive
        output = runner(dir, *args)
        process_output(output)
      end

      def run(file)
        output = runner(file)
        process_output(output)
      end

      def runner(filename, *args)
        # Load custome format definitions if present
        args << '-loadformats' << "#{formats.join(',')}" unless formats.empty?

        # Add filename to argument list (optional)
        args << "#{filename.escape_for_string}" if filename

        # Run command and capture results
        fido = ::Libis::Tools::Command.run(Libis::Format::Config[:fido_path], *args)

        # Log warning if needed
        warn "Fido errors: #{fido[:err].join("\n")}" unless fido[:err].empty?

        # Parse output (CSV) text into array and return result
        keys = [:status, :time, :puid, :format_name, :signature_name, :filesize, :filepath, :mimetype, :matchtype]
        result = CSV.parse(fido[:out].join("\n")).map {|a| Hash[keys.zip(a.values)]}.select {|a| a[:status] == 'OK'}
        result.each do |r|
          r.delete(:time)
          r.delete(:status)
          r.delete(:filesize)
          r[:source] = :fido
        end
      end

    end

  end
end
