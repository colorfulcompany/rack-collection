require "spec_helper"

require "simple_backstage_status/rack_server"
require_relative "../support/backstage"
require "uri"

describe Rack::MaintenanceMode::StatusChecker do
  include Rack::MaintenanceMode::Backstage

  after {
    @server.shutdown
  }

  describe "operational" do
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
      @port = @server.config[:Port]
    }

    describe "service exists" do
      it {
        checker = Rack::MaintenanceMode::StatusChecker.new(
          "http://localhost:#{@port}", {service: "service_a"}
        )

        assert {
          !checker.maintenance_mode?
        }
      }
    end

    describe "service does not exist" do
      it {
        checker = Rack::MaintenanceMode::StatusChecker.new(
          "http://localhost:#{@port}", {service: "service_b"}
        )

        assert {
          !checker.maintenance_mode?
        }
      }
    end
  end

  describe "maintenance" do
    before {
      @thread, @server = start_backstage_server(
        build_backstage_app(
          {
            hash: {
              services: [
                {
                  name: "service_a",
                  status: "maintenance",
                  description: "メンテナンス中です",
                  updated_at: Time.now
                }
              ]
            }
          }
        )
      )
      @port = @server.config[:Port]
    }

    it "service exist" do
      checker = Rack::MaintenanceMode::StatusChecker.new(
        "http://localhost:#{@port}", {service: "service_a"}
      )

      assert {
        checker.maintenance_mode?
      }
    end
  end
end
