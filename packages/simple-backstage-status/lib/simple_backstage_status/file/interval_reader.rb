module SimpleBackstageStatus
  module File
    class IntervalReader
      TTL = 10 # seconds

      #
      # @param [Number] ttl
      # @param [File] file
      #
      def initialize(ttl: TTL, file: ::File)
        @ttl = ttl
        @file = file
        @cache = {}
      end

      #
      # @param [String] path
      # @param [Time] now
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
