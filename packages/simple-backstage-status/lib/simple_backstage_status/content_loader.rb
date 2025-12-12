require_relative "content_loaders/json_loader"
require_relative "content_loaders/yaml_loader"
require_relative "content_loaders/ruby_loader"

module SimpleBackstageStatus
  module ContentLoader
    #
    # @param [Hash] loaders
    # @return [Hash]
    #
    def initialize_loaders!(loaders)
      @loaders = {
        json: ContentLoader::JsonLoader.new,
        yaml: ContentLoader::YamlLoader.new,
        ruby: ContentLoader::RubyLoader.new
      }.merge(loaders)
    end

    #
    # @param [String] uri
    # @return [JSON]
    #
    def load_content(uri)
      u = URI(uri)
      loader = @loaders.fetch(u.scheme.to_sym)

      if loader
        content = loader.call(u)
        content if content.size > 0
      end
    end
  end
end
