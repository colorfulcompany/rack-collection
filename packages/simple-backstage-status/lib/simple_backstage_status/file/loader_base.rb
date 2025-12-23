require_relative "resolver"
require_relative "interval_reader"

module SimpleBackstageStatus
  module File
    module LoaderBase
      include Resolver

      #
      # @param [File::IntervalReader] reader
      # @param [Numeric] ttl
      # @param [Logger] logger
      #
      def initialize(reader: IntervalReader, ttl: IntervalReader::TTL, logger: nil)
        @reader = reader.new(ttl: ttl, logger: logger)
        @logger = logger
      end
      attr_reader :logger
    end
  end
end
