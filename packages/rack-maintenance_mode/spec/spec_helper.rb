# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rack/maintenance_mode"

require "minitest/autorun"
require "minitest/reporters"
require "minitest-power_assert"
require "minitest/skip_dsl"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
