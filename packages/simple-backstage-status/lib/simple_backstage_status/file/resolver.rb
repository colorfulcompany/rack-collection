module SimpleBackstageStatus
  module File
    module Resolver
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
