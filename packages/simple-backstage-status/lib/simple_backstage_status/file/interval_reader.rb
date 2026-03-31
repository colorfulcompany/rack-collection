module SimpleBackstageStatus
  module File
    class IntervalReader
      # @return [Float]
      TTL = 10.0 # seconds

      # TTL がこの値以下のとき wall clock window を使わずキャッシュしない
      # @return [Float]
      MIN_CACHEABLE_TTL = 0.3 # seconds

      #
      # @param [Numeric] ttl
      # @param [File] file
      # @param [Logger] logger
      #
      def initialize(ttl: TTL, file: ::File, logger: nil)
        # @return [Float]
        @ttl = ttl.to_f
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
        window = window_for(now)

        if window.nil? || !@cache[path] || @cache.dig(path, :window) != window
          @cache[path] = {content: @file.read(path), window: window}
          logger&.info("#{self.class}: #{path} has read.")
        else
          logger&.info("#{self.class}: #{path} cache hit.")
        end

        @cache.dig(path, :content)
      end

      private

      def initialize_copy(orig)
        super
        @cache = {}
      end

      #
      # @param [Time] now
      # @return [Integer, nil] - nil when ttl is too small to cache (ttl <= 0.3)
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
