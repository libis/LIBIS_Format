# coding: utf-8

require 'singleton'
require 'yaml'

require 'libis/tools/logger'
require 'libis/tools/extend/hash'
require 'libis/tools/extend/string'

module Libis
  module Format

    class TypeDatabaseImpl
      include Singleton
      include ::Libis::Tools::Logger

      def typeinfo(t)
        @types[t.to_sym] || {}
      end

      def group_types(group)
        @types.select do |_, v|
          v[:GROUP] == group.to_sym
        end.keys
      end

      def puid_infos(puid)
        @types.select do |_, v|
          v[:PUID].include? puid rescue false
        end.values
      end

      def puid_types(puid)
        @types.select do |_, v|
          v[:PUID].include? puid rescue false
        end.keys
      end

      def mime_infos(mime)
        @types.select do |_, v|
          v[:MIME].include? mime rescue false
        end.values
      end

      def mime_types(mime)
        @types.select do |_, v|
          v[:MIME].include? mime rescue false
        end.keys
      end

      def ext_infos(ext)
        ext = ext.gsub /^\./, ''
        @types.select do |_, v|
          v[:EXTENSIONS].include?(ext) rescue false
        end.values
      end

      def ext_types(ext)
        ext = ext.gsub /^\./, ''
        @types.select do |_, v|
          v[:EXTENSIONS].include?(ext) rescue false
        end.keys
      end

      def puid_typeinfo(puid)
        @types.each do |_, v|
          return v if v[:PUID] and v[:PUID].include?(puid)
        end
        nil
      end

      def known_mime?(mime)
        @types.each do |_, v|
          return true if v[:MIME].include? mime
        end
        false
      end

      def groups
        @types.values.map(&:dig.call(:GROUP)).uniq
      end

      def export_csv(filename, **options)
        headers = @types.values.each_with_object(Set.new) { |v, s| v.each_key { |k| s << k.to_s } }
        options[:headers] = headers.to_a
        CSV.open(filename, 'w', **options) do |csv|
          @types.each_value do |v|
            csv << CSV::Row.new(v.keys, v.values.map { |x| x.is_a?(Array) ? x.join(', ') : x })
          end
        end
      end
      def load_types(file_or_hash = {}, append = true)
        hash = file_or_hash.is_a?(Hash) ? file_or_hash : YAML::load_file(file_or_hash)
        # noinspection RubyResolve
        hash.each do |group, type_info|
          type_info.each do |type_name, info|
            type_key = type_name.to_sym
            info.symbolize_keys!
            info[:TYPE] = type_key
            info[:GROUP] = group.to_sym
            info[:MIME] = info[:MIME].strip.split(/[\s,]+/).map(&:strip) rescue []
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
        type_database = Libis::Format::Config[:type_database]
        load_types(type_database)
      end

    end

  end
end
