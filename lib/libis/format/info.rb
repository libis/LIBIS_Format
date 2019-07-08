module Libis
  module Format
    class Info
      attr_reader :format, :category, :description, :puids, :mime_types, :extensions

      def initialize(format:, category:, description: '', puids: [], mime_types: [], extensions: [])
        @format = format
        @category = category
        @description = description
        @puids = puids
        @mime_types = mime_types
        @extensions = extensions
      end

      def to_hash
        {
            format: format,
            description: description.dup,
            category: category,
            puids: puids.dup,
            mime_types: mime_types.dup,
            extensions: extensions.dup
        }
      end
    end
  end
end
