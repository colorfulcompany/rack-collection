require_relative "resolver"
require_relative "interval_reader"

module SimpleBackstageStatus
  module File
    module LoaderBase
      include Resolver

      #
      # @param [File::IntervalReader] reader
      #
      def initialize(reader: IntervalReader)
        @reader = reader.new
      end
    end
  end
end
