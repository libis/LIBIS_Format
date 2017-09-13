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
    data_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'data'))
    Config[:fido_formats] = [(File.join(data_dir, 'lias_formats.xml'))]
    Config[:xml_validations] = {'archive/ead' => File.join(data_dir, 'ead.xsd')}

  end
end
