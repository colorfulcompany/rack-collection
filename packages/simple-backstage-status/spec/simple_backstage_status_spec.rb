# frozen_string_literal: true

require "spec_helper"

require "webrick"
require "rackup"
require "simple_backstage_status/rack_server"
require "simple_backstage_status/client"

#
# @param [Class] middleware
# @param [Hash] opts
# @return [Rack::Builder]
#
def build_app(middleware, opts = {})
  Rack::Builder.new do
    use middleware, opts
    run -> {}
  end
end

#
# @param [Rack::Builder] app
# @return [Thread]
#
def start_app(app)
  @server = WEBrick::HTTPServer.new(
    Port: 0,
    Logger: WEBrick::Log.new(File::NULL),
    AccessLog: []
  )
  @server.mount "/", Rackup::Handler::WEBrick, app

  Thread.new { @server.start }

  setup_client(@server)
end

#
# @param [WEBrick::HTTPServer] server
# @return [SimpleBackstageStatus::Client]
#
def setup_client(server)
  port = server.config[:Port]
  @client = SimpleBackstageStatus::Client.new("http://localhost:#{port}", service: :service_a)
end

describe SimpleBackstageStatus do
  describe "no servers waiting" do
    before {
      @client = SimpleBackstageStatus::Client.new("http://localhost:4000", service: :service_a)
    }

    it {
      assert {
        @client.service_status.failure.instance_of? Errno::ECONNREFUSED
      }
    }
  end

  describe "server connected" do
    after {
      @server.shutdown
    }

    describe "invalid json" do
      before {
        start_app(
          build_app(
            SimpleBackstageStatus::RackServer, {
              json: "invalid json content"
            }
          )
        )
      }

      it {
        result = @client.service_status

        assert { result.failure? }
        assert { result.failure.is_a? JSON::ParserError }
      }
    end

    describe "no info" do
      before {
        start_app(build_app(SimpleBackstageStatus::RackServer))
      }

      it {
        result = @client.service_status

        assert { result.failure? }
        assert { result.failure.is_a? Dry::Schema::Result }
      }
    end

    describe "no service" do
      before {
        start_app(
          build_app(
            SimpleBackstageStatus::RackServer, {
              hash: {
                services: [
                  {
                    name: :service_b,
                    status: "operational",
                    description: "通常通りご利用いただけます",
                    updated_at: Time.now
                  }
                ]
              }
            }
          )
        )
      }

      it {
        result = @client.service_status

        assert { result.failure? }
        assert { result.failure == :service_not_found }
      }
    end

    describe "degrade" do
      before {
        start_app(
          build_app(
            SimpleBackstageStatus::RackServer, {
              hash: {
                services: [
                  {
                    name: :service_a,
                    status: "degraded",
                    description: "一部の機能に問題があります",
                    updated_at: Time.now
                  }
                ]
              }
            }
          )
        )
      }

      it {
        result = @client.service_status

        assert { result.success? }
        assert { result.value! == "degraded" }
      }
    end

    describe "operational" do
      before {
        start_app(
          build_app(
            SimpleBackstageStatus::RackServer, {
              hash: {
                services: [
                  {
                    name: :service_a,
                    status: "operational",
                    description: "通常通りご利用いただけます",
                    updated_at: Time.now
                  }
                ]
              }
            }
          )
        )
      }

      it {
        result = @client.service_status

        assert { result.success? }
        assert { result.value! == "operational" }
      }
    end

    describe "with loader" do
      before {
        start_app(
          build_app(
            SimpleBackstageStatus::RackServer, {
              uri: "json://" + File.join(__dir__, "support/status.json")
            }
          )
        )
      }

      it {
        result = @client.service_status

        assert { result.failure? }
        assert { result.failure == :service_not_found }
      }
    end
  end
end
