module Libis
  module Format
    class Info
      def name
        raise NotImplementedError
      end

      def description
        raise NotImplementedError
      end

      def category
        raise NotImplementedError
      end

      def puids
        raise NotImplementedError
      end

      def mime_types
        raise NotImplementedError
      end

      def extensions
        raise NotImplementedError
      end

      def to_hash
        {
            name: name,
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
