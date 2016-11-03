# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pilot/version"

Gem::Specification.new do |spec|
  spec.name          = "pilot"
  spec.version       = Pilot::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["pilot@krausefx.com"]
  spec.summary       = Pilot::DESCRIPTION
  spec.description   = Pilot::DESCRIPTION
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.0.0"

  spec.files = Dir["lib/**/*"] + %w(bin/pilot README.md LICENSE)

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fastlane_core", ">= 0.53.0", "< 1.0.0" # all shared code and dependencies
  spec.add_dependency "spaceship", ">= 0.37.0", "< 1.0.0" # iTunes Connect communication
  spec.add_dependency 'credentials_manager', '>= 0.16.0'

  spec.add_dependency 'terminal-table', '>= 1.4.5', '< 2.0.0' # User's information

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', "~> 3.1.0"
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', "~> 0.8.7.4"
  spec.add_development_dependency 'webmock', "~> 1.19.0"
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'fastlane'
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
end
