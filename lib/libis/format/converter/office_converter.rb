# coding: utf-8

require_relative 'base'

module LIBIS
  module Format
    module Converter

      class OfficeConverter < Base

        def initialized?
          true
        end

        protected

        def init(source)
          @source = source
          @options = {orig_fname: File.basename(source)}

          debug "Initializing #{self.class} with '#{source}'"
        end

        def do_convert(target, format)
          unless format == :PDF
            error "Wrong target format requested: '#{format.to_s}'."
            return nil
          end
          cmd = 'office_convert'
          cmd += %{ "#{File.absolute_path(@source).to_s.escape_for_cmd}"}
          cmd += %{ "#{File.absolute_path(target).to_s.escape_for_cmd}"}
          cmd += %{ "#{@options[:orig_fname].to_s.decode_visual.gsub(/^\d+_/, '').escape_for_cmd}"}

          debug "Running converter command: '#{cmd}'"

          result = `#{cmd}`

          debug "Result: '#{result}'"

          target

        end

        private

        INPUT_TYPES = [
            :TXT,
            :RTF,
            :HTML,
            :MSDOC,
            :MSXLS,
            :MSPPT,
            :MSDOCX,
            :MSXLSX,
            :MSPPTX,
            :WORDPERFECT
        ]
        OUTPUT_TYPES = [:PDF]

        protected

        def self.input_types
          INPUT_TYPES
        end

        def self.output_types
          OUTPUT_TYPES
        end

      end
    end
  end
end
