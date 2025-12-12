require_relative "../file/loader_base"

module SimpleBackstageStatus
  module ContentLoader
    class RubyLoader
      include File::LoaderBase

      #
      # @param [URI] uri
      # @return [Hash]
      #
      def call(uri)
        instance_eval @reader.call(resolve_file_uri(uri))
      end
    end
  end
end
