require "json"
require_relative "../file/loader_base"

module SimpleBackstageStatus
  module ContentLoader
    class YamlLoader
      include File::LoaderBase

      #
      # @param [URI] uri
      # @return [Hash]
      #
      def call(uri)
        YAML.safe_load(@reader.call(resolve_file_uri(uri)))
      end
    end
  end
end
