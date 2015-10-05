# encoding: utf-8
require 'os'

module Libis
  module Format

    # noinspection RubyConstantNamingConvention
    Config = ::Libis::Tools::Config

    Config[:converter_chain_max_level] = 8

    Config[:java_path] = 'java'
    Config[:soffice_path] = 'soffice'
    Config[:ghostscript_path] = 'gs'
    Config[:pdfa_path] =
        File.absolute_path(
            File.join(
                File.dirname(__FILE__), '..', '..', '..', 'tools', 'pdf', 'pdfa', 'pdfa'
            )
        )
    Config[:droid_path] =
        File.absolute_path(
            File.join(
                File.dirname(__FILE__), '..', '..', '..', 'tools', 'droid', OS.windows? ? 'droid.bat' : 'droid.sh'
            )
        )
    Config[:fido_path] =
        File.absolute_path(
            File.join(
                File.dirname(__FILE__), '..', '..', '..', 'tools', 'fido', OS.windows? ? 'fido.bat' : 'fido.sh'
            )
        )

  end
end
