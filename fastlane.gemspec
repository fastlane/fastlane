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

  spec.add_dependency 'nokogiri', '~> 1.6' # generating JUnit reports for Jenkins
  spec.add_dependency 'krausefx-shenzhen', '>= 0.14.5' # to upload to Hockey and Crashlytics and build the app
  spec.add_dependency 'slack-notifier', '~> 1.0' # Slack notifications
  spec.add_dependency 'aws-sdk', '~> 1.0' # Upload ipa files to S3
  spec.add_dependency 'xcodeproj', '~> 0.20' # Needed for commit_version_bump action
  spec.add_dependency 'xcpretty', '>= 0.1.11' # prettify xcodebuild output
  spec.add_dependency 'terminal-notifier', '~> 1.6.2' # Mac OS X notifications
  spec.add_dependency 'terminal-table', '~> 1.4.5' # Actions documentation
  spec.add_dependency 'pbxplorer', '~> 1.0.0' # Manipulate xcproject files for provisioning profiles
  spec.add_dependency 'rest-client', '~> 1.8.0' # Needed for mailgun action
  spec.add_dependency 'plist', '~> 3.1.0' # Needed for set_build_number_repository and get_info_plist_value actions
  spec.add_dependency 'addressable', '~> 2.3.8' # Support for URI templates
  spec.add_dependency 'artifactory', '~> 2.0' # Needed for artifactory action
  spec.add_dependency 'slather', '~> 1.8' # Needed for artifactory action

  spec.add_dependency 'fastlane_core', '>= 0.15.3', '< 1.0.0' # all shared code and dependencies
  spec.add_dependency 'credentials_manager', '>= 0.7.4', '< 1.0.0' # Password Manager
  spec.add_dependency 'spaceship', '>= 0.5.3', '< 1.0.0' # communication layer with Apple's web services

  # All the fastlane tools
  spec.add_dependency 'deliver', '>= 0.13.4', '< 1.0.0'
  spec.add_dependency 'snapshot', '>= 0.9.2', '< 1.0.0'
  spec.add_dependency 'frameit', '>= 2.2.0', '< 3.0.0'
  spec.add_dependency 'pem', '>= 0.7.3', '< 1.0.0'
  spec.add_dependency 'cert', '>= 0.3.1', '< 1.0.0'
  spec.add_dependency 'sigh', '>= 0.10.6', '< 1.0.0'
  spec.add_dependency 'produce', '>= 0.6.1', '< 1.0.0'
  spec.add_dependency 'gym', '>= 0.4.5', '< 1.0.0'
  spec.add_dependency 'pilot', '>= 0.1.6', '< 1.0.0'

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop', '~> 0.29'
end
