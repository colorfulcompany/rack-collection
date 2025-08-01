require "net/http"
require "uri"
require "json"
require "simple_backstage_status/client"

module Rack
  class MaintenanceMode
    class StatusChecker
      #
      # @param [String] status_endpoint
      # @param [Hash] options
      #
      def initialize(status_endpoint, options = {})
        @endpoint = status_endpoint
        @options = options
      end
      attr_reader :endpoint

      #
      # @return [bool]
      #
      def maintenance_mode?
        SimpleBackstageStatus::Client.new(@endpoint, @options).service_status.either(
          ->(value) { value == "maintenance" },
          ->(failure) { false }
        )
      end
    end
  end
end
