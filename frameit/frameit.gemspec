# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'frameit/version'

Gem::Specification.new do |spec|
  spec.name          = "frameit"
  spec.version       = Frameit::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["frameit@krausefx.com"]
  spec.summary       = 'Quickly put your screenshots into the right device frames'
  spec.description   = 'Quickly put your screenshots into the right device frames'
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( bin/frameit README.md LICENSE )

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fastlane_core", ">= 0.58.0", "< 1.0.0" # all shared code and dependencies
  spec.add_dependency 'fastimage', '~> 1.6.3' # fetch the image sizes from the screenshots
  spec.add_dependency 'mini_magick', '~> 4.5.1' # To open, edit and export PSD files
  spec.add_dependency 'deliver', '> 0.3' # To determine the device type based on a screenshot file

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'fastlane'
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
end
