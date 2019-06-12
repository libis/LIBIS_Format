# encoding: utf-8

require_relative 'base'

require 'libis/format/tool/pdf_merge'

module Libis
  module Format
    module Converter

      # noinspection DuplicatedCode
      class PdfAssembler < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          [:PDF]
        end

        def self.category
          :assembler
        end

        def pdf_assemnble(_)
          #force usage of this converter
        end

        def convert(source, target, format, opts = {})
          super

          result = if source.is_a? Array
                     assemble(source, target)
                   elsif File.directory?(source)
                     source_list = Dir[File.join(source, '**', '*')].reject {|p| File.directory? p}
                     assemble(source_list, target)
                   else
                     assemble([source], target)
                   end
          return nil unless result

          result
        end

        private

        def assemble(source, target)

          result = Libis::Format::Tool::PdfMerge.run(source, target)

          unless result[:err].empty?
            error("PdfMerge encountered errors:\n%s", result[:err].join(join("\n")))
            return nil
          end

          target
        end

      end

    end

  end
end
