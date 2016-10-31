# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spaceship/version'

Gem::Specification.new do |spec|
  spec.name          = "spaceship"
  spec.version       = Spaceship::VERSION
  spec.authors       = ["Felix Krause", "Stefan Natchev"]
  spec.email         = ["spaceship@krausefx.com", "stefan@natchev.com"]
  spec.summary       = Spaceship::DESCRIPTION
  spec.description   = Spaceship::DESCRIPTION
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w(bin/spaceship bin/spaceauth README.md LICENSE)

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # fastlane specific
  spec.add_dependency 'credentials_manager', '>= 0.16.0' # to automatically get login information

  # external
  spec.add_dependency 'multi_xml', '~> 0.5'
  spec.add_dependency 'plist', '>= 3.1.0', '< 4.0.0'
  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'faraday_middleware', '~> 0.9'
  spec.add_dependency 'faraday-cookie_jar', '~> 0.0.6'
  spec.add_dependency 'fastimage', '~> 1.6'

  # for the playground
  spec.add_dependency 'colored'

  # Development only
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fastlane', ">= 1.15.0" # yes, we use fastlane to test fastlane
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'diff_matcher'
  spec.add_development_dependency 'multi_json'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.21.0'
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
end
