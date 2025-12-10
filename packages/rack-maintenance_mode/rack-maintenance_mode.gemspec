# frozen_string_literal: true

require_relative "lib/rack/maintenance_mode/version"

Gem::Specification.new do |spec|
  spec.name = "rack-maintenance_mode"
  spec.version = Rack::MaintenanceMode::VERSION
  spec.authors = ["Colorful Company,Inc."]

  spec.summary = "Rack middleware for handling maintenance mode with external status monitoring"
  spec.description = "A Rack middleware that provides maintenance mode functionality by monitoring external status endpoints or using custom checkers. Displays customizable maintenance pages when services are under maintenance."
  spec.homepage = "https://github.com/colorfulcompany/rack-collection/blob/main/packages/rack-maintenance_mode"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/colorfulcompany/rack-collection"
  spec.metadata["changelog_uri"] = "https://github.com/colorfulcompany/rack-collection/blob/main/packages/rack-maintenance_mode/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.each_line("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rack", "~> 3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
