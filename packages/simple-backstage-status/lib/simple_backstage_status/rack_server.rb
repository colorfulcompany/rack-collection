require "json"
require_relative "statuses"
require_relative "content_loader"
require_relative "file/interval_reader"

module SimpleBackstageStatus
  #
  # use SimpleBackstageStatus::RackServer, {
  #   uri: <String>,
  #   json: <String>,
  #   hash: <Hash>,
  #   loaders: Object
  # }
  #
  class RackServer
    include SimpleBackstageStatus::ContentLoader

    #
    # @param [#call] app
    # @param [Hash<Symbol, untyped>] options
    #
    def initialize(app, options = {})
      @app = app
      @options = options

      initialize_loaders!(
        options.fetch(:loaders) { {} },
        ttl: options.fetch(:ttl) { File::IntervalReader::TTL }
      )
    end

    #
    # @param [Hash] env
    # @return [Array(Integer, Hash, Array<String>)]
    #
    def call(env)
      [200, {"content-type" => "application/json"}, [content]]
    end

    #
    # @return [String]
    #
    def content
      if @options[:hash]
        @options[:hash].to_json
      elsif @options[:uri]
        # make a commitment to return object convertible to JSON
        load_content(@options[:uri]).to_json
      elsif @options[:json]
        @options[:json]
      else
        {}.to_json
      end
    end
  end
end
