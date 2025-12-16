module SimpleBackstageStatus
  module File
    class IntervalReader
      # @return [Numeric]
      TTL = 10 # seconds

      #
      # @param [Numeric] ttl
      # @param [File] file
      #
      def initialize(ttl: TTL, file: ::File)
        # @return [Numeric]
        @ttl = ttl
        # @return [File]
        @file = file
        # @return [Hash]
        @cache = {}
      end

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
          c[:last_read_at] = now

          @cache[path] = c
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
