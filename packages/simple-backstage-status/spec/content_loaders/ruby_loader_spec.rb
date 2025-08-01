require "spec_helper"

require "simple_backstage_status/content_loaders/ruby_loader"

describe SimpleBackstageStatus::ContentLoader::RubyLoader do
  def loader
    SimpleBackstageStatus::ContentLoader::RubyLoader
  end

  it "content exists" do
    content = loader.new.call(URI("ruby://" + File.join(__dir__, "/../support/status.rb")))

    assert { BackstageStatusSenderSchema.call(content).success? }
    assert { content.respond_to? :to_json }
  end

  it "content dost not exist" do
    assert_raises Errno::ENOENT do
      loader.new.call(URI("ruby://" + File.join(__dir__, "/../notexist.rb")))
    end
  end
end
