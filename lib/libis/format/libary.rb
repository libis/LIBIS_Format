# coding: utf-8

module Libis
  module Format

    # noinspection RubyClassVariableUsageInspection
    module Library

      @implementation = Libis::Format::Library::YamlLoader.instance

      class << self

        def implementation=(impl)
          @implementation = impl
        end

        def get_info(format)
          @implementation.get_info(format)
        end

        def get_info_by(key, value)
          @implementation.get_info_by(key,value)
        end

        def get_infos_by(key, value)
          @implementation.get_infos_by(key,value)
        end

        def enrich(info, map_keys = {})
          return {} unless info.is_a? Hash
          mapper = get_mapper(map_keys)
          # fill format name from looking up by puid
          unless (puids = info[mapper[:puids]]).blank?
            info[mapper[:name]] ||= get_info_by('puids', puids.first)[:name] rescue nil
          end
          # fill format name from looking up by mime_type
          unless (mimes = info[mapper[:mime_types]]).blank?
            info[mapper[:name]] ||= get_info_by('mime_types', mimes.first)[:name] rescue nil
          end
          # finally complete the information from looking up by format name
          unless (format_name = info[mapper[:name]]).nil?
            get_info(format_name)
            mapper.keys.each do |key|
              info[mapper[key]] = get_info(format_name)[key]
            end
            info[mapper[:GROUP]] = type_group(format_name)
          end
          info
        end

        protected

        def get_mapper(map_keys = {})
          mapper = Hash.new {|hash,key| hash[key] = key}
          mapper.merge! map_keys
        end

      end



      def self.enrich(info, map_keys = {})
        return {} unless info.is_a? Hash
        mapper = Hash.new {|hash,key| hash[key] = key}
        mapper.merge! map_keys
        unless (puid = info[mapper[:PUID]]).blank?
          info[mapper[:TYPE]] ||= puid_infos(puid).first[:TYPE] rescue nil
        end
        unless (mime = info[mapper[:MIME]]).blank?
          info[mapper[:TYPE]] ||= mime_infos(mime).first[:TYPE] rescue nil
        end
        unless (type_name = info[mapper[:TYPE]]).nil?
          mapper.keys.each do |key|
            info[mapper[key]] = get(type_name, key) || info[mapper[key]]
          end
          info[mapper[:GROUP]] = type_group(type_name)
        end
        info
      end

      def self.normalize(info, map_keys = {})
        return {} unless info.is_a? Hash
        mapper = Hash.new {|hash,key| hash[key] = key}
        mapper.merge! map_keys
        unless (puid = info[mapper[:PUID]]).blank?
          info[mapper[:TYPE]] ||= puid_infos(puid).first[:TYPE] rescue nil
        end
        unless (mime = info[mapper[:MIME]]).blank?
          info[mapper[:TYPE]] ||= mime_infos(mime).first[:TYPE] rescue nil
        end
        unless (type_name = info[mapper[:TYPE]]).nil?
          info[mapper[:MIME]] = type_mimetypes(type_name).first if type_mimetypes(type_name).first
          info[mapper[:GROUP]] = type_group(type_name)
        end
        info
      end

      def self.get(type_name, key)
        case key
          when :MIME
            type_mimetypes(type_name).first
          when :PUID
            type_puids(type_name).first
          when :EXTENSION
            type_extentions(type_name).first
          else
            typeinfo(type_name)[key]
        end
      end

      def self.type_group(t)
        typeinfo(t)[:GROUP]
      end

      def self.type_mimetypes(t)
        typeinfo(t)[:MIME] || []
      end

      def self.type_puids(t)
        typeinfo(t)[:PUID] || []
      end

      def self.type_extentions(t)
        typeinfo(t)[:EXTENSIONS] || []
      end

      def self.typeinfo(t)
        @implementation.typeinfo(t)
      end

      def self.group_types(group)
        @implementation.group_types(group)
      end

      def self.puid_infos(puid)
        @implementation.puid_infos(puid)
      end

      def self.puid_types(puid)
        @implementation.puid_types(puid)
      end

      def self.puid_groups(puid)
        puid_types(puid).map(&method(:type_group))
      end

      def self.mime_infos(mime)
        @implementation.mime_infos(mime)
      end

      def self.mime_types(mime)
        @implementation.mime_types(mime)
      end

      def self.mime_groups(mime)
        mime_types(mime).map(&method(:type_group))
      end

      def self.ext_infos(ext)
        @implementation.ext_infos(ext)
      end

      def self.ext_types(ext)
        @implementation.ext_types(ext)
      end

      def self.puid_typeinfo(puid)
        @implementation.puid_typeinfo(puid)
      end

      def self.known_mime?(mime)
        @implementation.known_mime?(mime)
      end

    end

  end
end
