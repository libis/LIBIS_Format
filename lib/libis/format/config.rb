# encoding: utf-8
require 'os'

module Libis
  module Format

    Config = ::Libis::Tools::Config

    Config[:converter_chain_max_level] = 8

    Config[:java_cmd] = 'java'
    Config[:j2k_cmd] = 'j2kdriver'
    Config[:soffice_cmd] = 'soffice'
    Config[:ghostscript_cmd] = 'gs'
    Config[:droid_cmd] = '/opt/droid/droid.sh'
    Config[:droid_temp_path] = '/tmp'
    Config[:fido_cmd] = '/usr/local/bin/fido'
    Config[:fop_jar] = File.join(Libis::Format::TOOL_DIR, 'fop', 'build', 'fop.jar')
    Config[:ffmpeg_cmd] = 'ffmpeg'
    Config[:fido_formats] = [(File.join(Libis::Format::DATA_DIR, 'lias_formats.xml'))]
    Config[:pdf_tool] = File.join(Libis::Format::TOOL_DIR, 'PdfTool.jar')
    Config[:preflight_jar] = File.join(Libis::Format::TOOL_DIR, 'pdfbox', 'preflight-app-2.0.13.jar')
    Config[:wkhtmltopdf] = 'wkhtmltopdf'
    Config[:xml_validations] = [['archive/ead', File.join(Libis::Format::DATA_DIR, 'ead.xsd')]]
    Config[:type_database] = File.join(Libis::Format::DATA_DIR, 'types.yml')
    Config[:raw_audio_convert_cmd] = 'sox -V1 %s -e signed -b 16 -t wav %s rate %d channels %d'
    Config[:watermark_font] = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'
    Config[:timeouts] = {
        droid: 20 * 60,
        ffmpeg: 5 * 60,
        fido: 20 * 60,
        file_tool: 5 * 60,
        fop: 5 * 60,
        identification_tool: 5 * 60,
        office_to_pdf: 5 * 60,
        email2pdf: 5 * 60,
        pdf_copy: 5 * 60,
        pdf_merge: 5 * 60,
        pdf_optimizer: 5 * 60,
        pdf_split: 5 * 60,
        pdf_to_pdfa: 5 * 60,
        pdfa_validator: 5 * 60,
    }

  end
end
