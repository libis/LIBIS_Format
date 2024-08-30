# frozen_string_literal: true

require 'tempfile'
require 'csv'
require 'fileutils'
require 'pdfinfo'

require 'libis/tools/extend/string'
require 'libis/tools/logger'
require 'libis/tools/command'
require 'libis/tools/temp_file'

require 'libis/format'

module Libis
  module Format
    module Tool
      class PdfToPdfa
        include ::Libis::Tools::Logger

        def self.installed?
          result = Libis::Tools::Command.run(Libis::Format::Config[:ghostscript_cmd])
          result.zero?
        end

        def self.run(source, target = nil, **options)
          new.run source, target, **options
        end

        def run(source, target = nil, **options)
          tmp_target = Tools::TempFile.name(File.basename(source, '.*'), '.pdf')
          target ||= tmp_target

          metadata = get_metadata(source)

          icc_info = icc_options(options[:colorspace])

          icc_file = Tools::TempFile.name(icc_info[:icc_name], '.icc')
          FileUtils.cp(File.join(Libis::Format::DATA_DIR, "#{icc_info[:icc_name]}.icc"), icc_file)

          def_filename = Tools::TempFile.name('PDFA_def', '.ps')
          File.open(def_filename, 'w') do |f|
            f.puts File.read(File.join(Libis::Format::DATA_DIR, 'PDFA_def.ps'))
                       .gsub('[**ICC profile**]', icc_file)
                       .gsub('[**ICC reference**]', icc_info[:icc_ref])
                       .gsub('[**METADATA**]', metadata)
          end

          timeout = Libis::Format::Config[:timeouts][:pdf_to_pdfa]
          result = Libis::Tools::Command.run(
            Libis::Format::Config[:ghostscript_cmd],
            '-q',
            '-dBATCH', '-dNOPAUSE', '-dNOOUTERSAVE', '-dNOSAFER',
            # "-dNOPLATFONTS", "-dUseCIEColor=true",
            # "-sColorConversionStrategy=/UseDeviceIndependentColor",
            "-sProcessColorModel=#{icc_info[:device]}",
            "-sOutputICCProfile=#{icc_file}",
            '-dCompatibilityLevel=1.4',
            '-sDEVICE=pdfwrite', '-dPDFA=1', '-dPDFACompatibilityPolicy=1',
            '-o', File.absolute_path(target),
            def_filename,
            source,
            timeout:,
            kill_after: timeout * 2
          )

          result[:err] << "#{self.class} took too long (> #{timeout} seconds) to complete" if result[:timeout]

          FileUtils.rm [icc_file, def_filename].compact, force: true

          result
        end

        private

        def get_metadata(source)
          info = Pdfinfo.new(source)
          metadata = "/Title (#{info.title})"
          metadata += "\n  /Author (#{info.author})" if info.author
          metadata += "\n  /Subject (#{info.subject})" if info.subject
          metadata += "\n  /Keywords (#{info.keywords})" if info.keywords
          metadata += "\n  /Creator (#{info.creator})" if info.creator
          metadata
        end

        def icc_options(colorspace)
          case colorspace.to_s.downcase
          when 'cmyk'
            { icc_name: 'ISOcoated_v2_eci', icc_ref: 'FOGRA39L', device: 'DeviceCMYK' }
          else
            { icc_name: 'AdobeRGB1998', icc_ref: 'sRGB', device: 'DeviceRGB' }
          end
        end
      end
    end
  end
end
