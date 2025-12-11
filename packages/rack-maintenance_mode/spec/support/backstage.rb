require "simple_backstage_status/rack_server"
require "rackup"
require "webrick"

module Rack
  class MaintenanceMode
    module Backstage
      #
      # @param [Hash] opts
      # @return [Rack::Builder]
      #
      def build_backstage_app(opts)
        Rack::Builder.new do
          use SimpleBackstageStatus::RackServer, opts
          run -> {}
        end
      end

      #
      # @param [Rack::Builder] app
      # @return [Array<Thread, Rack::Builder>]
      #
      def start_backstage_server(app)
        server = WEBrick::HTTPServer.new(
          Port: 0,
          Logger: WEBrick::Log.new(File::NULL),
          AccessLog: []
        )
        server.mount "/", Rackup::Handler::WEBrick, app

        t = Thread.new { server.start }

        [t, server]
      end
    end
  end
end
