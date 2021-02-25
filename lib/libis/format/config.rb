# encoding: utf-8
require 'os'
require 'libis-tools'

module Libis
  module Format

    # noinspection RubyConstantNamingConvention
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
    # noinspection RubyStringKeysInHashInspection
    Config[:xml_validations] = [['archive/ead', File.join(Libis::Format::DATA_DIR, 'ead.xsd')]]
    Config[:format_library_implementation] = 'Libis::Format::YamlLoader.instance'
    Config[:format_library_database] = File.join(Libis::Format::DATA_DIR, 'types.yml')
    Config[:raw_audio_convert_cmd] = 'sox -V1 %s -e signed -b 16 -t wav %s rate %d channels %d'
    Config[:watermark_font] = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'
    Config[:timeouts] = {
        droid: 20 * 60,
        ffmpeg: 500 * 60,
        fido: 20 * 60,
        file_tool: 20 * 60,
        fop: 50 * 60,
        identification_tool: 50 * 60,
        office_to_pdf: 50 * 60,
        pdf_select: 50 * 60,
        pdf_copy: 50 * 60,
        pdf_merge: 50 * 60,
        pdf_optimizer: 50 * 60,
        pdf_split: 50 * 60,
        pdf_watermark: 50 * 60,
        pdf_to_pdfa: 50 * 60,
        pdfa_validator: 50 * 60,
    }

  end
end
