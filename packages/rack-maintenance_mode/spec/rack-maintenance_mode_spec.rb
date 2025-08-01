# frozen_string_literal: true

require "spec_helper"

require_relative "support/backstage"

#
# @param [Hash]
# @return [Rack::Builder]
#
def maintenance_target(args)
  Rack::Builder.new do
    use Rack::MaintenanceMode, args
    run ->(_env) { [200, {"Content-Type" => "text/plain"}, ["OK"]] }
  end
end

describe Rack::MaintenanceMode do
  include Rack::MaintenanceMode::Backstage

  describe "no endpoint" do
    before {
      @target = maintenance_target({})
    }

    it "pass through to original app" do
      env = Rack::MockRequest.env_for("/")
      status, _headers, body = @target.call(env)

      assert { status == 200 }
      assert { body == ["OK"] }
    end
  end

  describe "status received" do
    after {
      @server.shutdown
    }

    describe "" do
      before {
        @thread, @server = start_backstage_server(
          build_backstage_app(
            {
              hash: {
                services: [
                  {
                    name: "service_a",
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

      it "not maintained" do
        @target = maintenance_target({status_endpoint: "http://localhost:4000", service: "service_a"})

        env = Rack::MockRequest.env_for("/")
        status, _headers, body = @target.call(env)

        assert { status == 200 }
        assert { body == ["OK"] }
      end

      it "expected service not found" do
        @target = maintenance_target({status_endpoint: "http://localhost:4000", service: "service_b"})

        env = Rack::MockRequest.env_for("/")
        status, _headers, body = @target.call(env)

        assert { status == 200 }
        assert { body == ["OK"] }
      end
    end

    describe "expected service now in maintenance" do
      before {
        @thread, @server = start_backstage_server(
          build_backstage_app(
            {
              hash: {
                services: [
                  {
                    name: "service_a",
                    status: "maintenance",
                    description: "現在メンテナンス中です",
                    updated_at: Time.now
                  }
                ]
              }
            }
          )
        )
      }

      it "inline page" do
        @target = maintenance_target({status_endpoint: "http://localhost:4000", service: "service_a"})

        env = Rack::MockRequest.env_for("/")
        status, _headers, body = @target.call(env)

        assert { status == 503 }
        assert { body == ["MaintenancePage"] }
      end

      describe "static file page" do
        before {
          @target = maintenance_target(
            {
              status_endpoint: "http://localhost:4000",
              service: "service_a",
              file: File.join(__dir__, "support/maintenance_page.html")
            }
          )
        }

        it "GET /" do
          env = Rack::MockRequest.env_for("/")
          status, _headers, body = @target.call(env)

          assert { status == 503 }
          assert { body.join("\n").include? "Maintenance Mode" }
        end

        it "POST /foo" do
          env = Rack::MockRequest.env_for("/foo", methods: "POST")
          status, _headers, body = @target.call(env)

          assert { status == 503 }
          assert { body.join("\n").include? "Maintenance Mode" }
        end
      end
    end
  end

  describe "custom maintenance mode checker" do
    it {
      @target = maintenance_target(checker: Struct.new(:maintenance_mode?).new(true))

      env = Rack::MockRequest.env_for("/")
      status, _headers, _body = @target.call(env)

      assert { status == 503 }
    }
  end
end
