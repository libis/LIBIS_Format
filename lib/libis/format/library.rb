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

      def get_info(format)
        @implementation.get_info(format)
      end

      def get_info_by(key, value)
        @implementation.get_info_by(key, value)
      end

      def get_infos_by(key, value)
        @implementation.get_infos_by(key, value)
      rescue
        []
      end

      def get_field(format, field)
        get_info(format)&.[](field)
      end

      def get_field_by(key, value, field)
        get_info_by(key, value)&.[](field)
      end

      def get_fields_by(key, value, field)
        get_infos_by(key, value)&.map { |info| info[field] }.compact
      end

      def known?(key, value)
        !get_info_by(key, value).nil?
      end

      def enrich(info, map_keys = {})
        info = normalize(info, map_keys)
        mapper = Hash.new { |hash, key| hash[key] = key }.merge(map_keys)
        unless (format = info[mapper[:TYPE]]).nil?
          lib_info = get_info(format)
          mapper.keys.each do |key|
            case key
            when :MIME
              info[mapper[key]] = lib_info[:mime_types].first
            when :PUID
              info[mapper[key]] = lib_info[:puids].first
            when :EXTENSION
              info[mapper[key]] = lib_info[:extensions].first
            else
              # do nothing
            end
          end
        end
        info
      end

      def normalize(info, map_keys = {})
        return {} unless info.is_a? Hash
        mapper = Hash.new { |hash, key| hash[key] = key }.merge(map_keys)
        # fill format from looking up by puid
        unless (puid = info[mapper[:PUID]]).blank?
          info[mapper[:TYPE]] ||= get_field_by(:puid, puid, :format)
        end
        # fill format from looking up by mime_type
        unless (mime = info[mapper[:MIME]]).blank?
          info[mapper[:TYPE]] ||= get_field_by(:mime_type, mime, :format)
        end
        # finally complete the information from looking up by format name
        unless (format = info[mapper[:TYPE]]).nil?
          info[mapper[:MIME]] = get_field(format, :mime_types).first
          info[mapper[:GROUP]] = get_field(format, :category)
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
