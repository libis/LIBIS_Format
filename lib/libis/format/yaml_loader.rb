# frozen_string_literal: true
require 'yaml'
require 'singleton'

module Libis
  module Format
    class YamlLoader
      # noinspection RubyResolve
      include Singleton

      def get_info(format)
        get_info_by(:format, format.to_sym)
      end

      def get_info_by(key, value)
        key = key.to_sym
        case key
        when :format
          database[value]
        when :category
          database.find { |_, info| info.category == value.to_sym }&.last
        when :puid
          database.find { |_, info| info.puids.include?(value) }&.last
        when :mime_type
          database.find { |_, info| info.mime_types.include?(value) }&.last
        when :extension
          database.find { |_, info| info.extensions.include?(value) }&.last
        else
          nil
        end&.to_hash
      end

      def get_infos_by(key, value)
        key = key.to_sym
        result = case key
                 when :format
                   return [database[key]]
                 when :category
                   database.find_all { |_, info| info.category == value.to_sym }
                 when :puid
                   database.find_all { |_, info| info.puids.include?(value) }
                 when :mime_type
                   database.find_all { |_, info| info.mime_types.include?(value) }
                 when :extension
                   database.find_all { |_, info| info.extensions.include?(value) }
                 else
                   return []
                 end
        Hash[result].values.map(&:to_hash)
      end

      def load_formats(file_or_hash)
        hash = file_or_hash.is_a?(Hash) ? file_or_hash : YAML::load_file(file_or_hash)
        hash.each do |category, format_list|
          format_list.each do |format_name, format_info|
            format_info.symbolize_keys!
            format_name = format_name.to_sym
            new_info = Libis::Format::Info.new(
                format: format_name,
                category: category.to_sym,
                description: format_info[:NAME],
                puids: format_info[:PUID]&.strip&.split(/[\s,]+/)&.map { |v| v.strip } || [],
                mime_types: format_info[:MIME]&.strip&.split(/[\s,]+/)&.map(&:strip) || [],
                extensions: format_info[:EXTENSIONS]&.strip&.split(/[\s,]+/)&.map { |v| v.strip } || []
            )
            if (old_info = database[format_name])
              new_info = Libis::Format::Info.new(
                  format: format_name,
                  category: category.to_sym,
                  description: new_info.description.blank? ? old_info.description : new_info.description,
                  puids: (old_info.puids + new_info.puids).uniq,
                  mime_types: (old_info.mime_types + new_info.mime_types).uniq,
                  extensions: (old_info.extensions + new_info.extensions).uniq
              )
            end
            database[format_name] = new_info
          end
        end

      end

      private

      attr_reader :database

      def initialize
        @database = {}
        format_database = Libis::Format::Config[:format_library_database]
        load_formats(format_database)
      end

    end

  end
end
