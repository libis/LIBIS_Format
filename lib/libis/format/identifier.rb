# encoding: utf-8

require 'singleton'
require 'csv'
require 'os'

require 'libis-tools'
require 'libis/tools/extend/string'
require 'libis/tools/extend/hash'
require 'libis/tools/extend/empty'

require 'libis/format/type_database'

require_relative 'droid'

module Libis
  module Format

    class Identifier
      include ::Libis::Tools::Logger
      include Singleton

      BAD_MIMETYPES = [nil, '', 'None', 'application/octet-stream']
      RETRY_MIMETYPES = %w(application/zip) + BAD_MIMETYPES
      FIDO_FAILURES = %w(application/vnd.oasis.opendocument.text application/vnd.oasis.opendocument.spreadsheet)

      attr_reader :fido_formats
      attr_reader :xml_validations

      protected

      def initialize
        data_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'data'))
        @fido_formats = [(File.join(data_dir, 'lias_formats.xml'))]
        # noinspection RubyStringKeysInHashInspection
        @xml_validations = {'archive/ead' => File.join(data_dir, 'ead.xsd')}
      end

      def result_ok?(result, who_is_asking = nil)
        result = ::Libis::Format::TypeDatabase.enrich(result, PUID: :puid, MIME: :mimetype)
        return false if result.empty?
        return true unless result[:TYPE].empty?
        return false if RETRY_MIMETYPES.include? result[:mimetype]
        return false if FIDO_FAILURES.include? result[:mimetype] and who_is_asking == :DROID
        !(result[:mimetype].empty? and result[:puid].empty?)
      end

      def get_mimetype(puid)
        ::Libis::Format::TypeDatabase.puid_typeinfo(puid)[:MIME].first rescue nil
      end

      def get_puid(mimetype)
        ::Libis::Format::TypeDatabase.mime_infos(mimetype).first[:PUID].first rescue nil
      end

      public

      def self.add_fido_format(f)
        instance.fido_formats << f
      end

      def self.fido_formats
        instance.fido_formats
      end

      def self.add_xml_validation(mimetype, xsd_file)
        instance.xml_validations[mimetype] = xsd_file
      end

      def self.xml_validations
        instance.xml_validations
      end

      def self.get(file_path, options = nil)
        instance.get file_path, options
      end

      def get(file, options = nil)

        unless File.exists? file
          error 'File %s cannot be found.', file
          return nil
        end
        if File.directory? file
          error '%s is a directory.', file
          return nil
        end

        options ||= {}

        result = {}

        # use FIDO
        # Note: FIDO does not always do a good job, mainly due to lacking container inspection.
        # FIDO misses should be registered in
        result = get_fido_identification(file, result, options[:formats]) unless options[:droid]

        # use DROID
        result = get_droid_identification file, result

        # use FILE
        result = get_file_identification(file, result)

        # Try file extension
        result = get_extension_identification(file, result)

        # determine XML type. Add custom types at runtime with
        # Libis::Tools::Format::Identifier.add_xml_validation('my_type', '/path/to/my_type.xsd')
        result = validate_against_xml_schema(file, result)

        result ? info("Identification of '#{file}': '#{result}'") : warn("Could not identify MIME type of '#{file}'")

        result
      end

      def get_fido_identification(file, result = {}, xtra_formats = nil)
        return result if result_ok? result
        fido_results = []
        formats = self.fido_formats.dup
        case xtra_formats
          when Array
            formats += xtra_formats
          when String
            formats << xtra_formats
          else
            # do nothing
        end

        ext = File.extname(file)

        bin_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'bin'))
        cmd = File.join(bin_dir, 'fido')
        args = []
        args << '-loadformats' << "#{formats.join(',')}" unless formats.empty?
        args << "#{file.escape_for_string}"
        fido = ::Libis::Tools::Command.run(cmd, *args)
        keys = [:status, :time, :puid, :format_name, :signature_name, :filesize, :filename, :mimetype, :matchtype]
        fido_output = CSV.parse(fido[:out].join("\n")).map { |a| Hash[keys.zip(a)] }
        debug "Fido output: #{fido_output.to_s}"
        fido_output.each do |x|
          if x[:status] == 'OK'
            x[:mimetype] = get_mimetype x[:puid] if x[:mimetype] == 'None'
            next if BAD_MIMETYPES.include? x[:mimetype]
            x[:score] = 5
            case x[:matchtype]
              when 'signature'
                x[:score] += 5
              when 'container'
                typeinfo = ::Libis::Format::TypeDatabase.puid_typeinfo(x[:puid])
                if typeinfo and typeinfo[:EXTENSIONS].include?(ext)
                  x[:score] += 2
                end
              else
                # do nothing
            end
            fido_results << x
          end
        end

        fido_results = fido_results.sort { |a, b| a[:score] <=> b[:score] }
        result.merge fido_results.last
        result[:method] = 'fido'

        debug "Fido MIME-type: #{result[:mimetype]} (PRONOM UID: #{result[:puid]})" unless result.empty?
        result
      end

      def get_droid_identification(file, result = {})
        return result if result_ok? result, :DROID
        droid_output = ::Libis::Format::Droid.run file
        debug "DROID: #{droid_output}"
        warn 'Droid found multiple matches; using first match only' if droid_output.size > 1
        result.clear
        droid_output = droid_output.first
        result[:mimetype] = droid_output[:mime_type].to_s.split(/[\s,]+/).find {|x| x =~ /.*\/.*/}
        result[:matchtype] = droid_output[:method]
        result[:puid] = droid_output[:puid]
        result[:format_name] = droid_output[:format_name]
        result[:format_version] = droid_output[:format_version]
        result[:method] = 'droid'

        debug "Droid MIME-type: #{result[:mimetype]} (PRONOM UID: #{result[:puid]})" if result
        result
      end

      def get_file_identification(file, result = nil)
        return result if result_ok? result
        result = {}
        begin
          output = ::Libis::Tools::Command.run('file', '-b', '--mime-type', "\"#{file.escape_for_string}\"")[:err]
          mimetype = output.strip.split
          if mimetype
            debug "File result: '#{mimetype}'"
            result[:mimetype] = mimetype
            result[:puid] = get_puid(mimetype)
          end
        rescue Exception
          # ignored
        end
        result[:method] = 'file'
        result
      end

      def get_extension_identification(file, result = nil)
        return result if result_ok? result
        result = {}
        info = ::Libis::Format::TypeDatabase.ext_infos(File.extname(file)).first
        debug "File extension info: #{info}"
        if info
          result[:mimetype] = info[:MIME].first rescue nil
          result[:puid] = info[:PUID].first rescue nil
        end
        result[:method] = 'extension'
        result
      end

      def validate_against_xml_schema(file, result)
        return result unless result[:mimetype] =~ /^(text|application)\/xml$/
        doc = ::Libis::Tools::XmlDocument.open file
        xml_validations.each do |mime, xsd_file|
          next unless xsd_file
          if doc.validates_against?(xsd_file)
            debug "XML file validated against XML Schema: #{xsd_file}"
            result[:mimetype] = mime
            result[:puid] = nil
            result = ::Libis::Format::TypeDatabase.enrich(result, PUID: :puid, MIME: :mimetype)
          end
        end
        result
      end

    end

  end
end
