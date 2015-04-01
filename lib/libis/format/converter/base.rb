# coding: utf-8

### require 'tools/string'

require 'libis/tools/logger'
require 'libis/format/type_database'

require_relative 'repository'

module Libis
  module Format
    module Converter

      class Base
        include Libis::Tools::Logger

        def input_types
          raise RuntimeError, 'Method #input_types needs to be overridden in converter'
        end

        protected

        def output_types
          raise RuntimeError, 'Method #output_types needs to be overridden in converter'
        end

        attr_accessor :source, :options, :flags

        def init(_)
          raise RuntimeError, 'Method #init should be implemented in converter'
        end

        def do_convert(_, _)
          raise RuntimeError, 'Method #do_convert should be implemented in converter'
        end

        public

        def initialize( source = nil, options = {}, flags = {} )
          @source = source
          @options = options ? options : {}
          @flags = flags ? flags : {}
          init(source.to_s rescue nil)
        end

        def convert(target, format = nil)
          do_convert(target, format)
        end

        def Base.inherited( klass )

          Repository.register klass

          class << self

            def conversions
              input_types.inject({}) do |input_type, hash|
                hash[input_type] = output_types
                hash
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
              conversions[input_type] and conversions[input_type].any? { |t| t == output_type }
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
