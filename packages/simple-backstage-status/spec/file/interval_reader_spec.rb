require "spec_helper"

require "benchmark"
require "simple_backstage_status/file/interval_reader"

def reader
  if !@reader
    @reader = SimpleBackstageStatus::File::IntervalReader.new(ttl: 3)
  end

  @reader
end

def nonexistent_file
  File.join(__dir__, "/../support/nonexist.json")
end

def existent_file
  File.join(__dir__, "/../support/status.json")
end

describe SimpleBackstageStatus::File::IntervalReader do
  describe "not exist" do
    it {
      assert_raises(Errno::ENOENT) {
        reader.call(nonexistent_file)
      }
    }
  end

  xdescribe "benchmark with same existent file" do
    describe "enable cache and reduce read time" do
      it {
        Benchmark.bm do |x|
          x.report {
            10.times.each { reader.call(existent_file) }
          }
        end
      }
    end

    describe "disable cache" do
      it {
        reader = SimpleBackstageStatus::File::IntervalReader.new(ttl: 0)

        Benchmark.bm do |x|
          x.report {
            10.times.each { reader.call(existent_file) }
          }
        end
      }
    end
  end
end
