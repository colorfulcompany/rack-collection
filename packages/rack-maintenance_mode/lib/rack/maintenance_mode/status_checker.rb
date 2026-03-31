require "net/http"
require "uri"
require "json"
require "simple_backstage_status/client"

module Rack
  class MaintenanceMode
    class StatusChecker
      # @return [Float]
      TTL = 10.0 # seconds
      # @return [Float]
      MIN_CACHEABLE_TTL = 0.3 # seconds

      #
      # @param [String] status_endpoint
      # @param [Hash] options
      #
      def initialize(status_endpoint, options = {})
        @endpoint = status_endpoint
        @options = options
        @ttl = options.fetch(:ttl) { TTL }.to_f
        @cache = {}
      end
      # @return [String]
      attr_reader :endpoint

      #
      # @param [Time] now
      # @return [bool]
      #
      def maintenance_mode?(now: current_time)
        now.freeze
        window = window_for(now)

        if window.nil? || @cache[:window] != window
          result = SimpleBackstageStatus::Client.new(@endpoint, @options).service_status.either(
            ->(value) { value == "maintenance" },
            ->(failure) { false }
          )
          @cache = {result: result, window: window}
        end

        @cache[:result]
      end

      private

      #
      # @param [Time] now
      # @return [Integer, nil]
      #
      def window_for(now)
        return nil if @ttl <= MIN_CACHEABLE_TTL

        (now.to_f / @ttl).floor
      end

      #
      # @return [Time] - UTC
      #
      def current_time
        Time.now.utc
      end
    end
  end
end
