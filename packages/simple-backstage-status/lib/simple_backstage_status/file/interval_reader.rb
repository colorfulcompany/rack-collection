module SimpleBackstageStatus
  module File
    class IntervalReader
      def call(path)
        ::File.read(path)
      end
    end
  end
end
