# froze_string_litteral: true
# coding: utf-8
require 'singleton'

module Libis
  module Format

    class Library
      include Singleton

      class << self
        def implementation=(impl)
          instance.implementation = impl
        end

        def get_info(format)
          instance.get_info(format)
        end

        def get_info_by(key, value)
          instance.get_info_by(key, value)
        end

        def get_infos_by(key, value)
          instance.get_infos_by(key, value)
        end

        def get_field(format, field)
          instance.get_field(format, field)
        end

        def get_field_by(key, value, field)
          instance.get_field_by(key, value, field)
        end

        def get_fields_by(key, value, field)
          instance.get_fields_by(key, value, field)
        end

        def known?(key, value)
          instance.known?(key, value)
        end

        def enrich(info, map_keys = {})
          instance.enrich(info, map_keys)
        end

        def normalize(info, map_keys = {})
          instance.normalize(info, map_keys)
        end
      end

      def implementation=(impl)
        @implementation = impl
      end

      def get_field(format, field)
        get_field_by(:name, format, field)
      end

      def get_field_by(key, value, field)
        info = get_info_by(key, value)
        return nil unless info
        case field
        when :mimetype
          info[:mimetypes]&.first
        when :puid
          info[:puids]&.first
        when :extension
          info[:extensions]&.first
        else
          info[field]
        end
      end

      def get_fields_by(key, value, field)
        get_infos_by(key, value)&.map { |info| info[field] }.compact
      end

      def get_info(format)
        get_info_by(:name, format)
      end

      def get_info_by(key, value)
        get_infos_by(key, value)&.first
      end

      def get_infos_by(key, value)
        result = @implementation.query(key, value)
        result.map(&:to_hash)
      end

      def known?(key, value)
        !get_info_by(key, value).nil?
      end

      def enrich(info, map_keys = {})
        info = normalize(info, map_keys)
        mapper = Hash.new { |hash, key| hash[key] = key }.merge(map_keys)
        unless (format = info[mapper[:name]]).nil?
          lib_info = get_info(format)
          mapper.keys.each do |key|
            case key
            when :mimetype
              info[mapper[key]] = lib_info[:mimetypes].first if lib_info[:mimetypes].first
            when :puid
              info[mapper[key]] = lib_info[:puids].first if lib_info[:puids].first
            when :extension
              info[mapper[key]] = lib_info[:extensions].first if lib_info[:extensions].first
            else
              info[mapper[key]] = lib_info[key] if lib_info[key]
            end
          end
        end
        info
      end

      # Derive name from the available info
      def normalize(info, map_keys = {})
        return {} unless info.is_a? Hash
        mapper = Hash.new { |hash, key| hash[key] = key }.merge(map_keys)
        # fill format from looking up by puid
        unless (puid = info[mapper[:puid]]).blank?
          info[mapper[:name]] ||= get_field_by(:puid, puid, :name)
        end
        # fill format from looking up by mimetype
        unless (mime = info[mapper[:mimetype]]).blank?
          info[mapper[:name]] ||= get_field_by(:mimetype, mime, :name)
        end
        # finally complete the information from looking up by format name
        unless (format = info[mapper[:name]]).nil?
          info[mapper[:mimetype]] = get_field(format, :mimetype)
          info[mapper[:category]] = get_field(format, :category)
        end
        info
      end

      private

      def initialize
        @implementation = eval(Libis::Format::Config[:format_library_implementation])
      end

    end

  end
end
