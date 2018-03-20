# encoding: utf-8
require 'os'

module Libis
  module Format

    # noinspection RubyConstantNamingConvention
    Config = ::Libis::Tools::Config

    Config[:converter_chain_max_level] = 8

    Config[:java_path] = 'java'
    Config[:j2kdriver] = 'j2kdriver'
    Config[:soffice_path] = 'soffice'
    Config[:ghostscript_path] = 'gs'
    Config[:droid_path] = '/opt/droid/droid.sh'
    Config[:fido_path] = '/usr/local/bin/fido'
    Config[:fop_jar] = '/opt/fop/current/fop/build/fop.jar'
    Config[:ffmpeg_path] = 'ffmpeg'
    Config[:fido_formats] = [(File.join(Libis::Format::DATA_DIR, 'lias_formats.xml'))]
    Config[:pdf_tool] = File.join(Libis::Format::TOOL_DIR, 'PdfTool.jar')
    # noinspection RubyStringKeysInHashInspection
    Config[:xml_validations] = [['archive/ead', File.join(Libis::Format::DATA_DIR, 'ead.xsd')]]
    Config[:type_database] = File.join(Libis::Format::DATA_DIR, 'types.yml')
    Config[:raw_audio_convert_cmd] = 'sox %s -e signed -b 16 -t wav %s rate %d channels %d'
    Config[:watermark_font] = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'
    Config[:timeouts] = {
        droid: 5 * 60,
        ffmpeg: 5 * 60,
        fido: 5 * 60,
        file_tool: 5 * 60,
        fop: 5 * 60,
        identification_tool: 5 * 60,
        office_to_pdf: 5 * 60,
        pdf_copy: 5 * 60,
        pdf_merge: 5 * 60,
        pdf_optimizer: 5 * 60,
        pdf_split: 5 * 60,
        pdf_to_pdfa: 5 * 60,
        pdfa_validator: 5 * 60,
    }

  end
end
