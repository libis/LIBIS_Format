module Libis
  module Format
    class Info
      attr_reader :name, :category, :description, :puids, :mimetypes, :extensions

      def initialize(name:, category:, description: '', puids: [], mimetypes: [], extensions: [])
        @name = name
        @category = category
        @description = description
        @puids = puids
        @mimetypes = mimetypes
        @extensions = extensions
      end

      def to_hash
        {
            name: name,
            description: description.dup,
            category: category,
            puids: puids.dup,
            mimetypes: mimetypes.dup,
            extensions: extensions.dup
        }
      end
    end
  end
end
