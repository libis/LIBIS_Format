require 'libis/format/version'

module Libis
  module Format
    autoload :TypeDatabase, 'libis/format/type_database'
    autoload :Identifier, 'libis/format/identifier'
    autoload :Fido, 'libis/format/fido'
    autoload :Droid, 'libis/format/droid'

    autoload :Converter, 'libis/format/converter'
  end
end