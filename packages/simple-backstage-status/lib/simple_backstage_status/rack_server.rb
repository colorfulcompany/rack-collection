require "json"
require_relative "statuses"
require_relative "content_loader"

module SimpleBackstageStatus
  #
  # use GcpSimpleStatusBackstage::RackServer, {
  #   uri: <String>,
  #   json: <String>,
  #   hash: <Hash>,
  #   content_loader: Object
  # }
  #
  class RackServer
    include SimpleBackstageStatus::ContentLoader

    def initialize(app, options = {})
      @app = app
      @options = options

      initialize_loaders!(options.fetch(:loaders) { {} })
    end

    def call(env)
      [200, {"Content-Type" => "application/json"}, [content]]
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
