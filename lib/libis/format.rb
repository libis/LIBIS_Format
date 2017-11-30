require 'libis/format/version'

module Libis
  module Format
    autoload :Config, 'libis/format/config'
    autoload :TypeDatabase, 'libis/format/type_database'
    autoload :Identifier, 'libis/format/identifier'

    autoload :Tool, 'libis/format/tool'
    autoload :Converter, 'libis/format/converter'

    ROOT_DIR = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..'))
    DATA_DIR = File.join(ROOT_DIR, 'data')
    TOOL_DIR = File.join(ROOT_DIR, 'tools')

  end
end