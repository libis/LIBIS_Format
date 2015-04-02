require 'os'
require 'csv'
require 'singleton'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'

require 'libis/format/type_database'

module Libis
  module Format

    class Fido
      include ::Libis::Tools::Logger
      include Singleton

      BAD_MIMETYPES = [nil, '', 'None', 'application/octet-stream']

      def self.run(file, formats)
        instance.run file, formats
      end

      def run(file, xtra_formats = nil)

        fido_results = []

        fmt_list = formats.dup
        case xtra_formats
          when Array
            fmt_list += xtra_formats
          when String
            fmt_list << xtra_formats
          else
            # do nothing
        end

        bin_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'bin', 'fido'))
        cmd = File.join(bin_dir, OS.windows? ? 'fido.bat' : 'fido.sh')
        args = []
        args << '-loadformats' << "#{fmt_list.join(',')}" unless fmt_list.empty?
        args << "#{file.escape_for_string}"
        fido = ::Libis::Tools::Command.run(cmd, *args)
        debug "Fido errors: #{fido[:err].join("\n")}" unless fido[:err].empty?

        keys = [:status, :time, :puid, :format_name, :signature_name, :filesize, :filename, :mimetype, :matchtype]
        fido_output = CSV.parse(fido[:out].join("\n")).map { |a| Hash[keys.zip(a)] }
        debug "Fido output: #{fido_output}"

        fido_output.each do |x|
          if x[:status] == 'OK'
            x[:mimetype] = get_mimetype(x[:puid]) if x[:mimetype] == 'None'
            next if BAD_MIMETYPES.include? x[:mimetype]
            x[:score] = 5
            case x[:matchtype]
              when 'signature'
                x[:score] += 5
              when 'container'
                typeinfo = ::Libis::Format::TypeDatabase.puid_typeinfo(x[:puid])
                ext = File.extname(file)
                x[:score] += 2 if typeinfo and typeinfo[:EXTENSIONS].include?(ext)
              else
                # do nothing
            end
            fido_results << x
          end
        end

        fido_results = fido_results.inject({}) do |result, value|
          result[value[:score]] ||= []
          result[value[:score]] << value
          result
        end

        debug "Fido results: #{fido_results}"

        max_score = fido_results.keys.max

        # Only if we find a single hit of type 'signature' or 'container', we are confident enough to return a result
        return result unless max_score and max_score >= 5 && fido_results[max_score].size == 1

        fido_results[max_score].first
      end

      def self.add_format(f)
        instance.formats << f
      end

      def self.formats
        instance.formats
      end

      protected

      attr_reader :formats

      def initialize
        data_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'data'))
        @formats = [(File.join(data_dir, 'lias_formats.xml'))]
      end

      def get_mimetype(puid)
        ::Libis::Format::TypeDatabase.puid_typeinfo(puid)[:MIME].first rescue nil
      end

    end

  end
end
