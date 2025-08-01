require "spec_helper"

require "simple_backstage_status/content_loaders/yaml_loader"

describe SimpleBackstageStatus::ContentLoader::YamlLoader do
  def loader
    SimpleBackstageStatus::ContentLoader::YamlLoader
  end

  it "content exists" do
    content = loader.new.call(URI("yaml://" + File.join(__dir__, "/../support/status.yaml")))

    assert { BackstageStatusSenderSchema.call(content).success? }
    assert { content.respond_to? :to_json }
  end

  it "content dost not exist" do
    assert_raises Errno::ENOENT do
      loader.new.call(URI("yaml://" + File.join(__dir__, "/../notexist.yaml")))
    end
  end
end
