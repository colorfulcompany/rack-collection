# frozen_string_literal: true

require "rack"
require_relative "maintenance_mode/maintenance_page_app"
require_relative "maintenance_mode/status_checker"

module Rack
  class MaintenanceMode
    #
    # examples:
    #
    # with Rack::MaintenanceMode::StatusChecker
    #
    # use Rack::MaintenanceMode, {
    #   status_endpoint: "http://example.com/status.json",
    #   service: "service_a"
    # }
    #
    # with some Config object with `#maintenance_mode?' method
    #
    # use Rack::MaintenanceMode, {
    #   checker: Config.new
    # }
    #
    # @param [Object] app - Rack application
    # @param [Hash] options
    #
    def initialize(app, options = {})
      @app = app
      @maintenance_page = MaintenancePageApp.new(app, options)
      @opts = options
      @checker =
        if @opts[:checker]&.respond_to?(:maintenance_mode?)
          @opts[:checker]
        else
          StatusChecker.new(@opts[:status_endpoint], {service: @opts[:service]})
        end
    end

    def call(env)
      if maintenance_mode?
        @maintenance_page.call(env)
      else
        @app.call(env)
      end
    end

    #
    # @return [bool]
    #
    def maintenance_mode?
      @checker.maintenance_mode?
    end
  end
end
