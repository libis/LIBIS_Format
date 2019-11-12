# frozen_string_literal: true
require 'yaml'
require 'singleton'

module Libis
  module Format
    class YamlLoader
      # noinspection RubyResolve
      include Singleton

      def query(key, value)
        case key.to_s.downcase.to_sym
        when :name
          return [database[value.to_s.upcase.to_sym]]
        when :category
          database.find_all { |_, info| info.category == value.to_s.upcase.to_sym }
        when :puid
          database.find_all { |_, info| info.puids.include?(value) }
        when :mimetype
          database.find_all { |_, info| info.mimetypes.include?(value) }
        when :extension
          database.find_all { |_, info| info.extensions.include?(value) }
        else
          return []
        end.map(&:last)
      end

      def load_formats(file_or_hash)
        hash = file_or_hash.is_a?(Hash) ? file_or_hash : YAML::load_file(file_or_hash)
        hash.each do |category, format_list|
          format_list.each do |format_name, format_info|
            format_info.symbolize_keys!
            format_name = format_name.to_sym
            new_info = Libis::Format::Info.new(
                name: format_name,
                category: category.to_sym,
                description: format_info[:NAME],
                puids: format_info[:PUID]&.strip&.split(/[\s,]+/)&.map { |v| v.strip } || [],
                mimetypes: format_info[:MIME]&.strip&.split(/[\s,]+/)&.map(&:strip) || [],
                extensions: format_info[:EXTENSIONS]&.strip&.split(/[\s,]+/)&.map { |v| v.strip } || []
            )
            if (old_info = database[format_name])
              new_info = Libis::Format::Info.new(
                  name: format_name,
                  category: category.to_sym,
                  description: new_info.description.blank? ? old_info.description : new_info.description,
                  puids: (old_info.puids + new_info.puids).uniq,
                  mimetypes: (old_info.mimetypes + new_info.mimetypes).uniq,
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
