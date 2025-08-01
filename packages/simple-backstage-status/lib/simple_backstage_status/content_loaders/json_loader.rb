require "json"
require_relative "file_resolver"

module SimpleBackstageStatus
  module ContentLoader
    class JsonLoader
      include FileResolver

      #
      # @param [URI] uri
      # @return [Hash]
      #
      def call(uri)
        JSON.parse(File.read(resolve_file_uri(uri)))
      end
    end
  end
end
