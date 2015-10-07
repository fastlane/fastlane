# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snapshot/version'

Gem::Specification.new do |spec|
  spec.name          = "snapshot"
  spec.version       = Snapshot::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["snapshot@krausefx.com"]
  spec.summary       = 'Automate taking localized screenshots of your iOS app on every device'
  spec.description   = 'Automate taking localized screenshots of your iOS app on every device'
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( bin/snapshot README.md LICENSE )

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'fastimage', '~> 1.6.3' # fetch the image sizes from the screenshots
  spec.add_dependency 'fastlane_core', '>= 0.7.2' # all shared code and dependencies
  spec.add_dependency 'xcpretty' # beautiful Xcode output

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'fastlane'
  spec.add_development_dependency 'rubocop', '~> 0.34'
end
