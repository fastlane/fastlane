# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane_core/version'

Gem::Specification.new do |spec|
  spec.name          = "fastlane_core"
  spec.version       = FastlaneCore::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["fastlanecore@krausefx.com"]
  spec.summary       = 'Contains all shared code/dependencies of the fastlane.tools'
  spec.description   = 'Contains all shared code/dependencies of the fastlane.tools'
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( README.md LICENSE )

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'json' # Because sometimes it's just not installed
  spec.add_dependency 'multi_json' # Because sometimes it's just not installed
  spec.add_dependency 'highline', '>= 1.7.2' # user inputs (e.g. passwords)
  spec.add_dependency 'colored' # coloured terminal output
  spec.add_dependency 'commander', '>= 4.4.0', '<= 5.0.0' # CLI parser
  spec.add_dependency 'babosa' # transliterate strings
  spec.add_dependency 'excon', '>= 0.45.0', '< 1.0' # Great HTTP Client
  spec.add_dependency 'rubyzip', '~> 1.1.6' # needed for extracting the ipa file
  spec.add_dependency 'plist', '>= 3.1.0', '< 4.0.0' # needed for parsing provisioning profiles
  spec.add_dependency 'terminal-table', '>= 1.4.5', '< 2.0.0' # options summary
  spec.add_dependency 'gh_inspector', '>= 1.0.1', '< 2.0.0' # search for issues on GitHub when something goes wrong

  spec.add_dependency "credentials_manager", ">= 0.16.2", "< 1.0.0" # fastlane password manager

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
  spec.add_development_dependency 'danger', '>= 0.1.1'
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
end
