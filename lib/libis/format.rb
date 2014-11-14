require 'libis/format/version'

module LIBIS
  module Format
    autoload :Identifier, 'libis/format/identifier'
    autoload :MimeType, 'libis/format/mime_type'
    autoload :TypeDatabase, 'libis/format/type_database'

    autoload :Converter, 'libis/format/converter'
  end
end