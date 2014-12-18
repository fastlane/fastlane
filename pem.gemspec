# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pem/version'

Gem::Specification.new do |spec|
  spec.name          = "pem"
  spec.version       = PEM::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["pem@krausefx.com"]
  spec.summary       = %q{Tired of creating and maintaining your push certification profiles? PEM does all that for you.}
  spec.description   = %q{Tired of creating and maintaining your push certification profiles? PEM helps you creating and maintaining your iOS push notification certificates.}
  spec.homepage      = "http://krausefx.com"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w{ bin/pem README.md LICENSE }

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'json' # Because sometimes it's just not installed
  spec.add_dependency 'highline', '~> 1.6.21' # user inputs (e.g. passwords)
  spec.add_dependency 'colored' # coloured terminal output
  spec.add_dependency 'commander', '~> 4.2.0' # CLI parser

  spec.add_dependency 'credentials_manager' # fastlane password manager

  # Frontend Scripting
  spec.add_dependency 'capybara', '~> 2.4.3' # for controlling iTC
  spec.add_dependency 'poltergeist', '~> 1.5.1' # headless Javascript browser for controlling iTC

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'codeclimate-test-reporter'

  spec.post_install_message = "This gem requires phantomjs. Install it using 'brew update && brew install phantomjs'"
end
