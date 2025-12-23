require_relative "content_loaders/json_loader"
require_relative "content_loaders/yaml_loader"
require_relative "content_loaders/ruby_loader"
require_relative "file/interval_reader"

module SimpleBackstageStatus
  module ContentLoader
    #
    # @param [Hash] loaders
    # @return [Hash]
    #
    def initialize_loaders!(loaders, ttl: File::IntervalReader::TTL, logger: nil)
      @loaders = {
        json: ContentLoader::JsonLoader.new(ttl: ttl, logger: logger),
        yaml: ContentLoader::YamlLoader.new(ttl: ttl, logger: logger),
        ruby: ContentLoader::RubyLoader.new(ttl: ttl, logger: logger)
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
