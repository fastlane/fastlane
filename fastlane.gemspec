# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/version'

Gem::Specification.new do |spec|
  spec.name          = "fastlane"
  spec.version       = Fastlane::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["fastlane@krausefx.com"]
  spec.summary       = 'Connect all iOS deployment tools into one streamlined workflow'
  spec.description   = 'Connect all iOS deployment tools into one streamlined workflow'
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( bin/fastlane README.md LICENSE )

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'krausefx-shenzhen', '>= 0.14.7' # to upload to Hockey and Crashlytics and build the app
  spec.add_dependency 'slack-notifier', '~> 1.3' # Slack notifications
  spec.add_dependency 'xcodeproj', '>= 0.20', '< 1.0.0' # Needed for commit_version_bump action
  spec.add_dependency 'xcpretty', '>= 0.2.1' # prettify xcodebuild output
  spec.add_dependency 'terminal-notifier', '~> 1.6.2' # Mac OS X notifications
  spec.add_dependency 'terminal-table', '~> 1.4.5' # Actions documentation
  spec.add_dependency 'plist', '~> 3.1.0' # Needed for set_build_number_repository and get_info_plist_value actions
  spec.add_dependency 'addressable', '~> 2.3.8' # Support for URI templates
  spec.add_dependency 'xcode-install', '~> 1.0.1' # Download new Xcode versions

  spec.add_dependency 'fastlane_core', '>= 0.31.0', '< 1.0.0' # all shared code and dependencies
  spec.add_dependency 'credentials_manager', '>= 0.13.0', '< 1.0.0' # Password Manager
  spec.add_dependency 'spaceship', '>= 0.19.0', '< 1.0.0' # communication layer with Apple's web services

  # All the fastlane tools
  spec.add_dependency 'deliver', '>= 1.6.5', '< 2.0.0'
  spec.add_dependency 'snapshot', '>= 1.4.2', '< 2.0.0'
  spec.add_dependency 'frameit', '>= 2.4.1', '< 3.0.0'
  spec.add_dependency 'pem', '>= 1.1.1', '< 2.0.0'
  spec.add_dependency 'cert', '>= 1.2.7', '< 2.0.0'
  spec.add_dependency 'sigh', '>= 1.2.1', '< 2.0.0'
  spec.add_dependency 'produce', '>= 1.1.0', '< 2.0.0'
  spec.add_dependency 'gym', '>= 1.1.6', '< 2.0.0'
  spec.add_dependency 'pilot', '>= 1.2.1', '< 2.0.0'
  spec.add_dependency 'supply', '>= 0.2.2', '< 1.0.0'
  spec.add_dependency 'scan', '>= 0.3.3', '< 1.0.0'
  spec.add_dependency 'match', '>= 0.2.2', '< 1.0.0'

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop', '~> 0.29'
  spec.add_development_dependency 'appium_lib', '~> 4.1.0'
end
