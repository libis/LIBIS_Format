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
    Config[:ffmpeg_path] = 'ffmpeg'
    data_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'data'))
    Config[:fido_formats] = [(File.join(data_dir, 'lias_formats.xml'))]
    # noinspection RubyStringKeysInHashInspection
    Config[:xml_validations] = [['archive/ead', File.join(data_dir, 'ead.xsd')]]
    Config[:type_database] = File.join(data_dir, 'types.yml')
    Config[:raw_audio_convert_cmd] = 'sox %s -e signed -b 16 -t wav %s rate %d channels %d'
    Config[:watermark_font] = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'

  end
end
