module SimpleBackstageStatus
  module ContentLoader
    module FileResolver
      #
      # @param [URI] uri
      # @return [String]
      #
      def resolve_file_uri(uri)
        uri.to_s.sub(Regexp.new("^#{uri.scheme}://"), "")
      end
    end
  end
end
