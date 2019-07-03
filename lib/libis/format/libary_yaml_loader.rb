# frozen_string_literal: true
# noinspection RubyResolve
require 'yaml'

module Libis
  module Format
    module Library

      class YamlLoader
        # noinspection RubyResolve
        include Singleton

        class Info < Libis::Format::Info
          attr_reader :name, :category, :description, :puids, :mime_types, :extensions

          def initialize(name:, category:, description: '', puids: [], mime_types: [], extensions: [])
            @name = name
            @category = category
            @description = description
            @puids = puids
            @mime_types = mime_types
            @extensions = extensions
          end
        end

        def get_info(format)
          get_info_by('name', format)
        end

        def get_info_by(key, value)
          key = key.to_sym
          case key
          when :name
            database[key]
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
          def get_infos_by(key, value)
            key = key.to_sym
            result = case key
                     when :name
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
        end

        def load_formats(file_or_hash)
          hash = file_or_hash.is_a?(Hash) ? file_or_hash : YAML::load_file(file_or_hash)
          hash.each do |category, format_list|
            format_list.each do |name, format_info|
              name_key = name.to_sym
              next if database[name_key]
              database[name_key] = Info.new(
                  name: name_key,
                  category: category.to_sym,
                  description: format_info[:NAME],
                  puids: format_info[:PUID]&.strip.split(/[\s,]+/).map { |v| v.strip } || [],
                  mime_types: format_info[:MIME]&.strip.split(/[\s,]+/).map(&:strip) || [],
                  extensions: format_info[:EXTENSIONS]&.strip.split(/[\s,]+/).map { |v| v.strip } || []
              )
            end

          end

          protected

          attr_reader :database

          def initialize
            @database = {}
            type_database = Libis::Format::Config[:type_database]
            load_formats(type_database)
          end

        end

      end
    end
  end
end
