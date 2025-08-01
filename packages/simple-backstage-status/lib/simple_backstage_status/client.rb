require "net/http"
require "json"
require "dry-monads"
require_relative "schema"

module SimpleBackstageStatus
  class Client
    include Dry::Monads[:result]

    #
    # @param [String] endpoint
    # @param [Hash] options
    #
    def initialize(endpoint, options = {})
      @endpoint = endpoint
      @service = options[:service]
      @schema = options.fetch(:schema) { BackstageStatusReceiverSchema }
    end
    attr_reader :endpoint, :service, :schema

    #
    # @return [Dry::Monads::Result<Net::HTTPResponse>]
    #
    def response
      return Failure("endpoint is nil") unless endpoint

      u = URI(endpoint)

      begin
        res = Net::HTTP.start(u.host, u.port) do |http|
          path = (u.path.size > 0) ? u.path : "/"
          http.get(path, {"Accept" => "application/json"})
        end

        begin
          res.value
          Success(res)
        rescue => e
          Failure(e)
        end
      rescue => e
        Failure(e)
      end
    end

    #
    # @return [Dry::Monads::Result<>]
    #
    def service_status
      result = response

      if result.success?
        res = result.value!
        begin
          info_whole = JSON.parse(res.body, symbolize_names: true)
          result = schema.call(info_whole)

          if result.success?
            extract_status(info_whole.dig(:services))
          else
            result.to_monad
          end
        rescue JSON::ParserError => e
          Failure(e)
        end
      else
        result
      end
    end

    #
    # @param [Array] services
    # @return [Dry::Schema::Monads<Symbol | String>]
    #
    def extract_status(services)
      info_service = services.find { |s|
        s.dig(:name) == service.to_s
      }

      if info_service.nil?
        Failure(:service_not_found)
      else
        Success(info_service.dig(:status))
      end
    end
  end
end
