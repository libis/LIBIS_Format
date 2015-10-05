# coding: utf-8

require 'singleton'
require 'yaml'

require 'backports/rails/hash'
require 'libis/tools/logger'
require 'libis/tools/extend/string'

module Libis
  module Format

    class TypeDatabase
      include Singleton
      include ::Libis::Tools::Logger

      def self.typeinfo(t)
        self.instance.types[t.to_sym] || {}
      end

      def self.enrich(info, map_keys = {})
        return {} unless info.is_a? Hash
        mapper = Hash.new {|hash,key| hash[key] = key}
        mapper.merge! map_keys
        unless (puid = info[mapper[:PUID]]).blank?
          info[mapper[:TYPE]] ||= self.puid_infos(puid).first[:TYPE] rescue nil
        end
        unless (mime = info[mapper[:MIME]]).blank?
          info[mapper[:TYPE]] ||= self.mime_infos(mime).first[:TYPE] rescue nil
        end
        unless (type_name = info[mapper[:TYPE]]).nil?
          info[mapper[:MIME]] = self.type_mimetypes(type_name).first if info[mapper[:MIME]].blank?
          info[mapper[:PUID]] = self.type_puids(type_name).first if info[mapper[:PUID]].blank?
          info[mapper[:EXTENSIONS]] = self.type_extentions(type_name)
          info[mapper[:GROUP]] = self.type_group(type_name)
        end
        info
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

      def self.group_types(group)
        self.instance.types.select do |_, v|
          v[:GROUP] == group.to_sym
        end.keys
      end

      def self.puid_infos(puid)
        self.instance.types.select do |_, v|
          v[:PUID].include? puid rescue false
        end.values
      end

      def self.puid_types(puid)
        self.instance.types.select do |_, v|
          v[:PUID].include? puid rescue false
        end.keys
      end

      def self.puid_groups(puid)
        puid_types(puid).map do |t|
          type_group t
        end
      end

      def self.mime_infos(mime)
        self.instance.types.select do |_, v|
          v[:MIME].include? mime rescue false
        end.values
      end

      def self.mime_types(mime)
        self.instance.types.select do |_, v|
          v[:MIME].include? mime rescue false
        end.keys
      end

      def self.mime_groups(mime)
        mime_types(mime).map do |t|
          type_group t
        end
      end

      def self.ext_infos(ext)
        ext = ext.gsub /^\./, ''
        self.instance.types.select do |_, v|
          v[:EXTENSIONS].include?(ext) rescue false
        end.values
      end

      def self.ext_types(ext)
        ext = ext.gsub /^\./, ''
        self.instance.types.select do |_, v|
          v[:EXTENSIONS].include?(ext) rescue false
        end.keys
      end

      def self.puid_typeinfo(puid)
        self.instance.types.each do |_, v|
          return v if v[:PUID] and v[:PUID].include?(puid)
        end
        nil
      end

      def self.known_mime?(mime)
        self.instance.types.each do |_, v|
          return true if v[:MIME].include? mime
        end
        false
      end

      attr_reader :types

      def load_types(file_or_hash = {}, append = true)
        hash = file_or_hash.is_a?(Hash) ? file_or_hash : YAML::load_file(file_or_hash)
        # noinspection RubyResolve
        hash.each do |group, type_info|
          type_info.each do |type_name, info|
            type_key = type_name.to_sym
            info.symbolize_keys!
            info[:TYPE] = type_key
            info[:GROUP] = group.to_sym
            info[:MIME] = info[:MIME].strip.split(/[\s,]+/).map { |v| v.strip } rescue []
            info[:EXTENSIONS] = info[:EXTENSIONS].strip.split(/[\s,]+/).map { |v| v.strip } rescue []
            info[:PUID] = info[:PUID].strip.split(/[\s,]+/).map { |v| v.strip } if info[:PUID]
            if @types.has_key?(type_key)
              warn 'Type %s already defined; merging with info from %s.', type_name.to_s, file_or_hash
              info.merge!(@types[type_key]) do |_,v_new,v_old|
                case v_old
                  when Array
                    append ? v_old + v_new : v_new + v_old
                  when Hash
                    append ? v_new.merge(v_old) : v_old.merge(v_new)
                  else
                    append ? v_old : v_new
                end
              end
            end
            @types[type_key] = info
          end
        end
      end

      protected

      def initialize
        @types = Hash.new
        data_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'data'))
        type_database = File.join(data_dir, 'types.yml')
        load_types(type_database)
      end

    end

  end
end
