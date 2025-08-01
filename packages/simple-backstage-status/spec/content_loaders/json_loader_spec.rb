require "spec_helper"

require "simple_backstage_status/content_loaders/json_loader"

describe SimpleBackstageStatus::ContentLoader::JsonLoader do
  def loader
    SimpleBackstageStatus::ContentLoader::JsonLoader
  end

  it "content exists" do
    content = loader.new.call(URI("json://" + File.join(__dir__, "/../support/status.json")))

    assert { BackstageStatusSenderSchema.call(content).success? }
    assert { content.respond_to? :to_json }
  end

  it "content dost not exist" do
    assert_raises Errno::ENOENT do
      loader.new.call(URI("json://" + File.join(__dir__, "/../notexist.json")))
    end
  end
end
