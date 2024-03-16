# frozen_string_literal: true

require 'singleton'
require 'pathname'

require 'libis-tools'
require 'libis/tools/extend/hash'
require 'libis/tools/extend/string'
require 'libis/tools/extend/empty'

require 'libis/format/type_database'

require_relative 'config'
require_relative 'tool/fido'
require_relative 'tool/droid'
require_relative 'tool/file_tool'
require_relative 'tool/extension_identification'

module Libis
  module Format
    class Identifier
      include ::Libis::Tools::Logger
      include Singleton

      def self.add_xml_validation(mimetype, xsd_file)
        instance.xml_validations[mimetype] = xsd_file
      end

      def self.xml_validations
        instance.xml_validations
      end

      def self.get(file, options = {})
        instance.get file, options
      end

      attr_reader :xml_validations

      def get(file, options = {})
        options[:droid] = true unless options.keys.include?(:droid) || (options[:tool] && (options[:tool] != :droid))
        options[:fido] = true unless options.keys.include?(:fido) || (options[:tool] && (options[:tool] != :fido))
        options[:file] = true unless options.keys.include?(:file) || (options[:tool] && (options[:tool] != :file))
        options[:xml_validation] = true if options[:xml_validation].nil?

        result = { messages: [], output: {}, formats: {} }

        begin
          get_droid_identification(file, result, options) if options[:droid]
        rescue StandardError => e
          log_msg(result, :error, "Error running Droid: #{e.message} @ #{e.backtrace.first}")
        end

        begin
          get_fido_identification(file, result, options) if options[:fido]
        rescue StandardError => e
          log_msg(result, :error, "Error running Fido: #{e.message} @ #{e.backtrace.first}")
        end

        begin
          get_file_identification(file, result, options) if options[:file]
        rescue StandardError => e
          log_msg(result, :error, "Error running File: #{e.message} @ #{e.backtrace.first}")
        end

        # Let's not waiste time on this. If not standard, it will fail in Rosetta anyway.
        # get_extension_identification(file, options[:recursive], result)

        # determine XML type. Add custom types at runtime with
        # Libis::Tools::Format::Identifier.add_xml_validation('my_type', '/path/to/my_type.xsd')
        begin
          validate_against_xml_schema(result, options[:base_dir]) if options[:xml_validation]
        rescue StandardError => e
          log_msg(result, :error, "Error validating XML files: #{e.message} @ #{e.backtrace.first}")
        end

        process_results(result, !options[:keep_output])

        result
      end

      protected

      def initialize
        @xml_validations = Libis::Format::Config[:xml_validations].to_h
      end

      def get_file_identification(file, result, options)
        output = ::Libis::Format::Tool::FileTool.run(file, options[:recursive])
        process_tool_output(output, result, options[:base_dir])
        output
      end

      def get_fido_identification(file, result, options)
        output = ::Libis::Format::Tool::Fido.run(file, options[:recursive], **(options[:fido_options] || {}))
        process_tool_output(output, result, options[:base_dir])
        output
      end

      def get_droid_identification(file, result, options)
        output = ::Libis::Format::Tool::Droid.run(file, options[:recursive])
        process_tool_output(output, result, options[:base_dir])
        output
      end

      def get_extension_identification(file, result, options)
        output = ::Libis::Format::Tool::ExtensionIdentification.run(file, options[:recursive])
        process_tool_output(output, result, options[:base_dir])
        output
      end

      def validate_against_xml_schema(result, base_dir)
        result[:output].each do |file, file_results|
          file_results.each do |file_result|
            xml_validate(file, file_result, result, base_dir)
          end
        end
      end

      def xml_validate(file, file_result, result, base_dir)
        return unless file_result[:mimetype] =~ %r{^(text|application)/xml$}

        filepath = base_dir ? File.join(base_dir, file) : file
        doc = ::Libis::Tools::XmlDocument.open filepath
        xml_validations.each do |mime, xsd_file|
          next unless xsd_file

          begin
            if doc.validates_against?(xsd_file)
              log_msg result, :debug, "XML file validated against XML Schema: #{xsd_file}"
              info = { mimetype: mime, tool_raw: file_result[:tool], tool: :xsd_validation, match_type: 'xsd_validation',
                       format_version: '' }
              file_result.merge! Libis::Format::TypeDatabase.enrich(info, PUID: :puid, MIME: :mimetype, NAME: :format_name)
            end
          rescue StandardError => e
            # Do nothing - probably Nokogiri chrashed during validation. Could have many causes
            # (remote schema (firewall, network, link rot, ...), schema syntax error, corrupt XML,...)
            # so we log and continue.
            log_msg(result, :warn,
                    "Error during XML validation of file #{file} against #{File.basename(xsd_file)}: #{e.message}")
          end
        end
      rescue StandardError => e
        # Not much we can do. probably Nokogiri chrashed opening the XML file. What caused this?
        # (XML not parsable, false XML identification, ???)
        # so we log and continue.
        log_msg(result, :warn, "Error parsing XML file #{file}: #{e.message} @ #{e.backtrace.first}")
      end

      def process_results(result, delete_output = true)
        result[:output].each_key do |file|
          output = result[:output][file]
          file_result = result[:formats][file] = {}
          if output.empty?
            log_msg(result, :warn, "Could not identify format of '#{file}'.")
            file_result.merge!(
              mimetype: 'application/octet-stream',
              puid: 'fmt/unknown',
              score: 0,
              tool: nil
            )
          else
            format_matches = output.group_by { |x| [x[:mimetype], x[:puid]] }
            format_matches.each do |match, group|
              format_matches[match] = group.group_by { |x| x[:score] }.sort.reverse.to_h
            end
            case format_matches.count
            when 0
              # No this really cannot happen. If there are no hits, there will be at least a format [nil,nil]
            when 1
              # only one match, that's easy. The first of the highest score will be used
              file_result.merge!(get_best_result(output))
            else
              process_multiple_formats(file_result, format_matches, output)
            end
          end
        end
        result.delete(:output) if delete_output
      end

      def process_multiple_formats(file_result, format_matches, output)
        # multiple matches. Let's select the highest score matches
        file_result.merge!(get_best_result(output))
        file_result[:alternatives] = []
        format_matches.each_key do |mime, puid|
          next if file_result[:mimetype] == mime && puid.nil?

          selection = output.select { |x| x[:mimetype] == mime && x[:puid] == puid }
          file_result[:alternatives] << get_best_result(selection)
        end
        file_result[:alternatives] = file_result[:alternatives].sort_by { |x| x[:score] }.reverse
        file_result.delete(:alternatives) if file_result[:alternatives].size <= 1
      end

      private

      def process_tool_output(output, result, base_dir)
        output.each do |file, file_output|
          file = Pathname.new(file).relative_path_from(Pathname(File.absolute_path(base_dir))).to_s.freeze if base_dir
          result[:output][file] ||= []
          result[:output][file] += file_output
        end
      end

      def log_msg(result, severity, text)
        result[:messages] << [severity, text]
      end

      def get_mimetype(puid)
        ::Libis::Format::TypeDatabase.puid_typeinfo(puid)[:MIME].first
      rescue StandardError
        nil
      end

      def get_best_result(results)
        score = results.map { |x| x[:score] }.max
        results.select { |x| x[:score] == score }.reduce(:apply_defaults)
      end
    end
  end
end
