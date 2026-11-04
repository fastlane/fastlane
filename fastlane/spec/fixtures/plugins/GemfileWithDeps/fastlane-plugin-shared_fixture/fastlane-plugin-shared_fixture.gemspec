# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = 'fastlane-plugin-shared_fixture'
  spec.version     = '1.0.0'
  spec.authors     = ["fastlane team"]

  spec.required_ruby_version = '>= 3.2'

  spec.summary = "fake fastlane plugin for fastlane tests"

  spec.files = Dir.glob("lib/**/*")
end
