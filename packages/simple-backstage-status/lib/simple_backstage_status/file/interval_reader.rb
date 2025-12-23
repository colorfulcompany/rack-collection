module SimpleBackstageStatus
  module File
    class IntervalReader
      # @return [Numeric]
      TTL = 10 # seconds

      #
      # @param [Numeric] ttl
      # @param [File] file
      # @param [Logger] logger
      #
      def initialize(ttl: TTL, file: ::File, logger: nil)
        # @return [Numeric]
        @ttl = ttl
        # @return [File]
        @file = file
        # @return [Hash]
        @cache = {}

        @logger = logger
      end
      # @return [Logger]
      attr_reader :logger

      #
      # @param [String] path
      # @param [Time] now
      # @return [String]
      #
      def call(path, now: current_time)
        now.freeze

        if !@cache[path] || !@cache.dig(path, :last_read_at) || @cache.dig(path, :last_read_at) + @ttl <= now
          c = {}
          c[:content] = @file.read(path)
          logger&.info(self, "#{path} has read.")
          c[:last_read_at] = now

          @cache[path] = c
        else
          logger&.info(self, "#{path} cache hit.")
        end

        @cache.dig(path, :content)
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
