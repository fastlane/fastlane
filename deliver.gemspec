# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deliver/version'

Gem::Specification.new do |spec|
  spec.name          = "deliver"
  spec.version       = Deliver::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["deliver@krausefx.com"]
  spec.summary       = %q{Upload screenshots, metadata and your app to the App Store using a single command}
  spec.description   = %q{Upload screenshots, metadata and your app to the App Store using a single command}
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w{ bin/deliver README.md LICENSE }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'fastlane_core', '>= 0.15.1' # all shared code and dependencies
  spec.add_dependency 'credentials_manager', '>= 0.3.0'
  spec.add_dependency 'nokogiri', '~> 1.6.5' # parsing and updating XML files
  spec.add_dependency 'fastimage', '~> 1.6.3' # fetch the image sizes from the screenshots
  spec.add_dependency 'rubyzip', '~> 1.1.6' # needed for extracting the ipa file
  spec.add_dependency 'plist', '~> 3.1' # for reading the Info.plist of the ipa file
  spec.add_dependency 'excon' # HTTP client

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
end
