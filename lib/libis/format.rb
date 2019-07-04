require 'libis/format/version'

module Libis
  module Format
    autoload :Config, 'libis/format/config'
    autoload :TypeDatabase, 'libis/format/type_database'
    autoload :TypeDatabaseImpl, 'libis/format/type_database_impl'
    autoload :Identifier, 'libis/format/identifier'

    autoload :Info, 'libis/format/info'
    autoload :Library, 'libis/format/libary'

    module Library
      autoload :YamlLoader, 'libis/format/libary_yaml_loader'
    end

    autoload :Tool, 'libis/format/tool'
    autoload :Converter, 'libis/format/converter'

    ROOT_DIR = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..'))
    DATA_DIR = File.join(ROOT_DIR, 'data')
    TOOL_DIR = File.join(ROOT_DIR, 'tools')

  end
end