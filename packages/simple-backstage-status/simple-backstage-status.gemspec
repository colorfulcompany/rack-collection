# frozen_string_literal: true

require_relative "lib/simple_backstage_status/version"

Gem::Specification.new do |spec|
  spec.name = "simple-backstage-status"
  spec.version = SimpleBackstageStatus::VERSION
  spec.authors = ["Colorful Company,Inc."]
  spec.email = ["watanabe@colorfulcompany.co.jp"]

  spec.summary = "system state delivering server and client library"
  spec.description = "A library that consists of a rack server, which makes it easy to build a system for managing and distributing the operational status of services, and a client that can receive this information and determine the status of the status after checking it with a predefined schema."
  spec.homepage = "https://github.com/colorfulcompany/rack-collection"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/simple-backstage-status/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.each_line("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "dry-schema"
  spec.add_dependency "dry-monads"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
