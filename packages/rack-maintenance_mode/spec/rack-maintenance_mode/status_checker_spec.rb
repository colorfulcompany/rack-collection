require "spec_helper"

require "simple_backstage_status/rack_server"
require_relative "../support/backstage"
require "uri"

describe Rack::MaintenanceMode::StatusChecker do
  include Rack::MaintenanceMode::Backstage

  after {
    @server&.shutdown
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

  describe "wall clock alignment ( ttl: 10s )" do
    before {
      @checker = Rack::MaintenanceMode::StatusChecker.new(
        "http://localhost", {service: "service_a", ttl: 10}
      )
      @spy = Minitest::Mock.new
    }

    it "秒境界でHTTPリクエストが更新される" do
      2.times { @spy.expect(:service_status, Dry::Monads::Success("operational")) }

      SimpleBackstageStatus::Client.stub(:new, @spy) do
        @checker.maintenance_mode?(now: Time.at(10).utc)  # window=1, miss
        @checker.maintenance_mode?(now: Time.at(19).utc)  # window=1, hit
        @checker.maintenance_mode?(now: Time.at(20).utc)  # window=2, miss
      end
      @spy.verify
    end

    it "同一ウィンドウ内の 2 回目アクセスはキャッシュヒットになる" do
      @spy.expect(:service_status, Dry::Monads::Success("operational"))

      SimpleBackstageStatus::Client.stub(:new, @spy) do
        @checker.maintenance_mode?(now: Time.at(15).utc)  # window=1, miss
        @checker.maintenance_mode?(now: Time.at(17).utc)  # window=1, hit
      end
      @spy.verify
    end
  end
end
