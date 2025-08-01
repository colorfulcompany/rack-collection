require_relative "file_resolver"

module SimpleBackstageStatus
  module ContentLoader
    class RubyLoader
      include FileResolver

      #
      # @param [URI] uri
      # @return [Hash]
      #
      def call(uri)
        instance_eval File.read(resolve_file_uri(uri))
      end
    end
  end
end
