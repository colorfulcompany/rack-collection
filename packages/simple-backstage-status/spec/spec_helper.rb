# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "simple-backstage-status"

require "minitest/autorun"
require "minitest/skip_dsl"
require "minitest-power_assert"
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
