require_relative "resolver"
require_relative "interval_reader"

module SimpleBackstageStatus
  module File
    module LoaderBase
      include Resolver

      #
      # @param [File::IntervalReader] reader
      #
      def initialize(reader: IntervalReader, ttl: IntervalReader::TTL)
        @reader = reader.new(ttl: ttl)
      end
    end
  end
end
