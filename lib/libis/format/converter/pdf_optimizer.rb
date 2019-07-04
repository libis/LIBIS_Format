# encoding: utf-8

require_relative 'base'

require 'libis/tools/extend/hash'
require 'libis/format/tool/pdf_copy'
require 'libis/format/tool/pdf_to_pdfa'
require 'libis/format/tool/pdf_optimizer'

module Libis
  module Format
    module Converter

      class PdfOptimizer < Libis::Format::Converter::Base

        def self.input_types
          [:PDF]
        end

        def self.output_types(format = nil)
          [:PDF]
        end

        def pdf_optimize(_)
          #force usage of this converter
        end

        # Optimize the PDF
        #
        # This reduces the graphics quality to a level in order to limit file size. This option relies on the
        # presence of ghostscript and takes one argument: the quality level. It should be one of:
        #
        # - 0 : lowest quality (Acrobat Distiller 'Screen Optimized' equivalent)
        # - 1 : medium quality (Acrobat Distiller 'eBook' equivalent)
        # - 2 : good quality
        # - 3 : high quality (Acrobat Distiller 'Print Optimized' equivalent)
        # - 4 : highest quality (Acrobat Distiller 'Prepress Optimized' equivalent)
        #
        # Note that the optimization is intended to be used with PDF's containing high-resolution images.
        #
        # @param [Integer] setting quality setting. [0-4]
        def quality(setting = 1)
          @quality = %w(screen ebook default printer prepress)[setting] if (0..4) === setting
        end

        def convert(source, target, format, opts = {})
          super

           optimize_pdf(source, target, @quality || 'ebook')

        end

        def optimize_pdf(source, target, quality)

          using_temp(target) do |tmpname|
            result = Libis::Format::Tool::PdfOptimizer.run(source, tmpname, quality)
            unless result[:status] == 0
              error("Pdf optimization encountered errors:\n%s", (result[:err] + result[:out]).join("\n"))
              next nil
            end
            tmpname
          end
        end

      end

    end
  end
end
