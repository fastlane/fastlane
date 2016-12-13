# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/version'

# Copy over the latest .rubocop.yml style guide
rubocop_config = File.expand_path('../../.rubocop.yml', __FILE__)
`cp #{rubocop_config} #{lib}/fastlane/plugins/template/.rubocop.yml`

Gem::Specification.new do |spec|
  spec.name          = "fastlane"
  spec.version       = "2.0.0"
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

  spec.add_dependency 'slack-notifier', '>= 1.3', '< 2.0.0' # Slack notifications
  spec.add_dependency 'xcodeproj', '>= 0.20', '< 2.0.0' # Needed for commit_version_bump action
  spec.add_dependency 'xcpretty', '>= 0.2.4', '< 1.0.0' # prettify xcodebuild output
  spec.add_dependency 'terminal-notifier', '>= 1.6.2', '< 2.0.0' # macOS notifications
  spec.add_dependency 'terminal-table', '>= 1.4.5', '< 2.0.0' # Actions documentation
  spec.add_dependency 'plist', '>= 3.1.0', '< 4.0.0' # Needed for set_build_number_repository and get_info_plist_value actions
  spec.add_dependency 'addressable', '>= 2.3', '< 3.0.0' # Support for URI templates
  spec.add_dependency 'multipart-post', '~> 2.0.0' # Needed for uploading builds to appetize
  spec.add_dependency 'xcode-install', '~> 2.0.0' # Needed for xcversion and xcode_install actions
  spec.add_dependency 'word_wrap', '~> 1.0.0' # to add line breaks for tables with long strings

  spec.add_dependency "fastlane_core", ">= 0.60.0", "< 1.0.0" # all shared code and dependencies

  spec.add_dependency 'bundler', "~> 1.12" # Used for fastlane plugins
  spec.add_dependency "credentials_manager", ">= 0.16.2", "< 1.0.0" # Password Manager
  spec.add_dependency "spaceship", ">= 0.39.0", "< 1.0.0" # communication layer with Apple's web services
  spec.add_dependency 'faraday', '~> 0.9' # Used for deploygate, hockey and testfairy actions
  spec.add_dependency 'faraday_middleware', '~> 0.9' # same as faraday

  # All the fastlane tools
  spec.add_dependency "deliver", ">= 1.16.2", "< 2.0.0"
  spec.add_dependency "snapshot", ">= 1.17.0", "< 2.0.0"
  spec.add_dependency "frameit", ">= 3.0.0", "< 4.0.0"
  spec.add_dependency "pem", ">= 1.4.1", "< 2.0.0"
  spec.add_dependency "cert", ">= 1.4.5", "< 2.0.0"
  spec.add_dependency "sigh", ">= 1.12.1", "< 2.0.0"
  spec.add_dependency "produce", ">= 1.4.0", "< 2.0.0"
  spec.add_dependency "gym", ">= 1.13.0", "< 2.0.0"
  spec.add_dependency "pilot", ">= 1.13.0", "< 2.0.0"
  spec.add_dependency "scan", ">= 0.14.2", "< 1.0.0"
  spec.add_dependency "supply", ">= 0.8.0", "< 1.0.0"
  spec.add_dependency "match", ">= 0.11.1", "< 1.0.0"
  spec.add_dependency 'screengrab', '>= 0.5.2', '< 1.0.0'

  # Lock `activesupport` (transitive depedency via `xcodeproj`) to keep supporting system ruby
  spec.add_dependency 'activesupport', '< 5'

  # Development only
  spec.add_development_dependency 'rake', '< 12'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls', '~> 0.8.13'
  spec.add_development_dependency 'rubocop', '~> 0.45'
  spec.add_development_dependency 'rest-client', '~> 1.6.7'
  spec.add_development_dependency 'fakefs', '~> 0.8.1'

  spec.post_install_message = "\e[1;33;40mPlease use `fastlane #{spec.name}` instead of `#{spec.name}` from now on.\e[0m"
end
