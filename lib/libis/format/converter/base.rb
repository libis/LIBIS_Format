# frozen_string_literal: true

### require 'tools/string'
require 'tmpdir'
require 'libis/tools/logger'
require 'libis/tools/temp_file'
require 'libis/format/type_database'

require_relative 'repository'

module Libis
  module Format
    module Converter
      class Base
        include Libis::Tools::Logger

        attr_reader :options, :flags

        def initialize
          @options = {}
          @flags = {}
        end

        def convert(source, _target, _format, opts = {})
          unless File.exist? source
            error "Cannot find file '#{source}'."
            return nil
          end
          @options.merge!(opts[:options]) if opts[:options]
          @flags.merge!(opts[:flags]) if opts[:flags]
        end

        def self.input_types
          raise 'Method #input_types needs to be overridden in converter'
        end

        def self.output_types(_format = nil)
          raise 'Method #output_types needs to be overridden in converter'
        end

        def using_temp(target, &block)
          self.class.using_temp(target, &block)
        end

        def self.using_temp(target)
          tempfile = Tools::TempFile.name("convert-#{File.basename(target, '.*').gsub(/\s/, '_')}", File.extname(target))
          result = yield tempfile
          return nil unless result

          FileUtils.move result, target
          target
        end

        def self.inherited(klass) # rubocop:disable Lint/MissingSuper
          Repository.register klass

          class << self
            def conversions
              input_types.each_with_object({}) do |input_type, hash|
                hash[input_type] = output_types
              end
            end

            def input_type?(type_id)
              input_types.include? type_id
            end

            def output_type?(type_id)
              output_types.include? type_id
            end

            def input_mimetype?(mimetype)
              type_id = TypeDatabase.instance.mime_types(mimetype).first
              input_type? type_id
            end

            def output_mimetype?(mimetype)
              type_id = TypeDatabase.instance.mime_types(mimetype).first
              output_type? type_id
            end

            def conversion?(input_type, output_type)
              conversions[input_type]&.any? { |t| t == output_type }
            end

            def output_for(input_type)
              conversions[input_type]
            end

            def extension?(extension)
              !TypeDatabase.ext_types(extension).first.nil?
            end
          end
        end
      end
    end
  end
end
