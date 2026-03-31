require "spec_helper"

require "benchmark"
require "simple_backstage_status/file/interval_reader"

def nonexistent_file
  File.join(__dir__, "/../support/nonexist.json")
end

def existent_file
  File.join(__dir__, "/../support/status.json")
end

describe SimpleBackstageStatus::File::IntervalReader do
  describe "not exist" do
    before {
      @reader = SimpleBackstageStatus::File::IntervalReader.new(ttl: 3)
    }
    it {
      assert_raises(Errno::ENOENT) {
        @reader.call(nonexistent_file)
      }
    }
  end

  describe "wall clock alignment ( ttl: 10s )" do
    before {
      @spy = Minitest::Mock.new
      @reader = SimpleBackstageStatus::File::IntervalReader.new(ttl: 10)
    }

    it "秒境界でキャッシュが更新される" do
      2.times { @spy.expect(:call, "content", ["path"]) }

      ::File.stub(:read, @spy) do
        @reader.call("path", now: Time.at(10).utc)  # window=1, miss
        @reader.call("path", now: Time.at(19).utc)  # window=1, hit
        @reader.call("path", now: Time.at(20).utc)  # window=2, miss
      end
      @spy.verify
    end

    it "同一ウィンドウ内の 2 回目アクセスはキャッシュヒットになる" do
      @spy.expect(:call, "content", ["path"])

      ::File.stub(:read, @spy) do
        @reader.call("path", now: Time.at(15).utc)  # window=1, miss
        @reader.call("path", now: Time.at(17).utc)  # window=1, hit
      end
      @spy.verify
    end

    it "ウィンドウ内の読み込み時刻が異なる 2 インスタンスが同じ境界で更新される" do
      4.times { @spy.expect(:call, "content", ["path"]) }

      ::File.stub(:read, @spy) do
        r1, r2 = @reader.dup, @reader.dup
        r1.call("path", now: Time.at(10).utc)  # window=1, miss
        r2.call("path", now: Time.at(19).utc)  # window=1, miss (r2 first read)
        r1.call("path", now: Time.at(20).utc)  # window=2, miss
        r2.call("path", now: Time.at(20).utc)  # window=2, miss
      end
      @spy.verify
    end
  end

  describe "ttl <= 0.3 (no cache)" do
    before { @spy = Minitest::Mock.new }

    [0, SimpleBackstageStatus::File::IntervalReader::MIN_CACHEABLE_TTL].each do |ttl|
      it "ttl=#{ttl} のときキャッシュしない" do
        2.times { @spy.expect(:call, "content", ["path"]) }

        ::File.stub(:read, @spy) do
          r = SimpleBackstageStatus::File::IntervalReader.new(ttl: ttl)
          t = Time.at(10).utc
          r.call("path", now: t)
          r.call("path", now: t)
        end
        @spy.verify
      end
    end
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
