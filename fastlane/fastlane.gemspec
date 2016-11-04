# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/version'

# Copy over the latest .rubocop.yml style guide
rubocop_config = File.expand_path('../../.rubocop.yml', __FILE__)
`cp #{rubocop_config} #{lib}/fastlane/plugins/template/.rubocop.yml`

Gem::Specification.new do |spec|
  spec.name          = "fastlane"
  spec.version       = Fastlane::VERSION
  spec.authors       = ["Felix Krause", "Michael Furtak", "Andrea Falcone", "Sam Phillips", "David Ohayon", "Sam Robbins", "Mark Pirri", "Hemal Shah"]
  spec.email         = ["fastlane@krausefx.com"]
  spec.summary       = Fastlane::DESCRIPTION
  spec.description   = Fastlane::DESCRIPTION
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir.glob("lib/**/*", File::FNM_DOTMATCH) + %w(bin/fastlane bin/🚀 README.md LICENSE) - Dir.glob("lib/fastlane/actions/device_grid/assets/*")

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'krausefx-shenzhen', '>= 0.14.10', '< 1.0.0' # to upload to Hockey and Crashlytics and build the app
  spec.add_dependency 'slack-notifier', '>= 1.3', '< 2.0.0' # Slack notifications
  spec.add_dependency 'xcodeproj', '>= 0.20', '< 2.0.0' # Needed for commit_version_bump action
  spec.add_dependency 'xcpretty', '>= 0.2.4', '< 1.0.0' # prettify xcodebuild output
  spec.add_dependency 'terminal-notifier', '>= 1.6.2', '< 2.0.0' # macOS notifications
  spec.add_dependency 'terminal-table', '>= 1.4.5', '< 2.0.0' # Actions documentation
  spec.add_dependency 'plist', '>= 3.1.0', '< 4.0.0' # Needed for set_build_number_repository and get_info_plist_value actions
  spec.add_dependency 'addressable', '>= 2.3', '< 3.0.0' # Support for URI templates
  spec.add_dependency 'multipart-post', '~> 2.0.0' # Needed for uploading builds to appetize
  spec.add_dependency 'xcode-install', '~> 2.0.0' # Needed for xcversion and xcode_install actions
  spec.add_dependency 'word_wrap', '~> 1.0.0'  # to add line breaks for tables with long strings

  spec.add_dependency "fastlane_core", ">= 0.53.0", "< 1.0.0" # all shared code and dependencies

  spec.add_dependency 'bundler', "~> 1.12" # Used for fastlane plugins
  spec.add_dependency "credentials_manager", ">= 0.16.2", "< 1.0.0" # Password Manager
  spec.add_dependency "spaceship", ">= 0.37.0", "< 1.0.0" # communication layer with Apple's web services

  # All the fastlane tools
  spec.add_dependency "deliver", ">= 1.15.0", "< 2.0.0"
  spec.add_dependency "snapshot", ">= 1.16.3", "< 2.0.0"
  spec.add_dependency "frameit", ">= 3.0.0", "< 4.0.0"
  spec.add_dependency "pem", ">= 1.4.0", "< 2.0.0"
  spec.add_dependency "cert", ">= 1.4.3", "< 2.0.0"
  spec.add_dependency "sigh", ">= 1.11.2", "< 2.0.0"
  spec.add_dependency "produce", ">= 1.3.0", "< 2.0.0"
  spec.add_dependency "gym", ">= 1.12.0", "< 2.0.0"
  spec.add_dependency "pilot", ">= 1.12.0", "< 2.0.0"
  spec.add_dependency "scan", ">= 0.14.0", "< 1.0.0"
  spec.add_dependency "supply", ">= 0.7.1", "< 1.0.0"
  spec.add_dependency "match", ">= 0.10.0", "< 1.0.0"
  spec.add_dependency 'screengrab', '>= 0.5.2', '< 1.0.0'

  # Lock `activesupport` (transitive depedency via `xcodeproj`) to keep supporting system ruby
  spec.add_dependency 'activesupport', '< 5'

  # Development only
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls', '~> 0.8.13'
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
  spec.add_development_dependency 'rest-client', '~> 1.6.7'
  spec.add_development_dependency 'fakefs', '~> 0.8.1'
end
