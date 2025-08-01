require "json"
require_relative "file_resolver"

module SimpleBackstageStatus
  module ContentLoader
    class YamlLoader
      include FileResolver

      #
      # @param [URI] uri
      # @return [Hash]
      #
      def call(uri)
        YAML.load_file(resolve_file_uri(uri))
      end
    end
  end
end
