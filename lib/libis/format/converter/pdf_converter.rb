# coding: utf-8

require 'libis/format/mime_type'

require_relative 'base'

module LIBIS
  module Format
    module Converter

      class PdfConverter < Base

        def initialized?
          !@source.nil?
        end

        def range(selection)
          @options[:ranges] = selection
        end

        def watermark(options = {})
          watermark_info = options[:watermark_info]
          if watermark_info.nil?
            @wm_text = ['© LIBIS']
          elsif File.exist? watermark_info
            @wm_image = watermark_info
          else
            #noinspection RubyResolve
            @wm_text = watermark_info.spit('\n')
          end

        end

        protected

        def init(source)
          @options ||= {}
          @source = source

          unless PdfConverter.input_mimetype?(MimeType.get(@source))
            error "Supplied file '#{@source}' is not a PDF file."
          end

        end

        def do_convert(target, format)

          result = ''

          unless @options.empty?

            tmp_target = target
            tmp_target += '.pdf' if format == :PDFA

            cmd = "pdf_copy.sh --file_input \"#{@source}\" --file_output \"#{tmp_target}\""

            @options.each do |k, v|
              cmd += " --#{k.to_s} #{v}"
            end

            cmd += " --wm_image \"#{@wm_image}\"" if @wm_image

            if @wm_text
              cmd += ' --wm_text'
              @wm_text.each { |t| cmd += " \"#{t}\"" }
            end

            debug "Converting PDF using: '#{cmd}'"
            result += %x[#{cmd}]
            debug "Conversion result: #{result}"

            @source = tmp_target if format == :PDFA

          end

          if format == :PDFA
            cmd = 'gs -dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor -sProcessColorModel=DeviceCMYK -sDEVICE=pdfwrite'
            cmd += ' -dPDFACompatibilityPolicy=1'
            cmd += " -sOutputFile=#{target}"
            cmd += " #{File.absolute_path(File.join(File.dirname(__FILE__),'..','..','..','..','data','PDFA_def.ps'))}"
            cmd += " #{@source}"

            debug "Converting PDF to PDFA using: '#{cmd}'"
            result += %x[#{cmd}]
            debug "Conversion result: #{result}"
          end


          result
        end

        private

        INPUT_TYPES = [:PDF]
        OUTPUT_TYPES = [:PDF, :PDFA]

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