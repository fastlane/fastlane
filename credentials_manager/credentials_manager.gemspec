# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'credentials_manager/version'

Gem::Specification.new do |spec|
  spec.name          = "credentials_manager"
  spec.version       = CredentialsManager::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["fastlane@krausefx.com"]
  spec.summary       = 'Password manager used in fastlane.tools'
  spec.description   = 'Password manager used in fastlane.tools'
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( README.md LICENSE )

  spec.executables   = %w(fastlane-credentials)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'colored' # coloured terminal output
  spec.add_dependency 'commander', '>= 4.3.5' # CLI parser
  spec.add_dependency 'highline', '>= 1.7.1' # user inputs (e.g. passwords)
  spec.add_dependency 'security' # Mac OS Keychain manager

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'fastlane'
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
end
