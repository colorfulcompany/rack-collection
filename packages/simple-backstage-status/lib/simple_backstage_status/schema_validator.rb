require "json"
require "dry/schema"
require_relative "schema"

Dry::Schema.load_extensions(:monads)

module SimpleBackstageStatus
  class SchemaValidator
    #
    # @param [BackstageStatusSenderSchema] schema
    #
    def initialize(schema: BackstageStatusSenderSchema)
      @schema = schema
    end

    #
    # @param [String] json
    # @return [Dry::Monads::Result]
    #
    def call(json)
      @schema.call(JSON.parse(json)).to_monad
    end
  end
end
