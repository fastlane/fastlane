# coding: utf-8

lib = File.expand_path('../fastlane/lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/version'

# Copy over the latest .rubocop.yml style guide
require 'yaml'
rubocop_config = File.expand_path('../.rubocop.yml', __FILE__)
config = YAML.safe_load(open(rubocop_config))
config.delete("require")
File.write("#{lib}/fastlane/plugins/template/.rubocop.yml", YAML.dump(config))

Gem::Specification.new do |spec|
  spec.name          = "fastlane"
  spec.version       = Fastlane::VERSION
  # list of authors is regenerated and resorted on each release
  spec.authors       = ["Andrew McBurney",
                        "Felix Krause",
                        "Kohki Miki",
                        "Jimmy Dee",
                        "Jorge Revuelta H",
                        "Jérôme Lacoste",
                        "Olivier Halligon",
                        "Stefan Natchev",
                        "Manu Wallner",
                        "Helmut Januschka",
                        "Danielle Tomlinson",
                        "Fumiya Nakamura",
                        "Luka Mirosevic",
                        "Josh Holtz",
                        "Joshua Liebowitz",
                        "Aaron Brager",
                        "Jan Piotrowski",
                        "Maksym Grebenets",
                        "Matthew Ellis",
                        "Iulian Onofrei"]

  spec.email         = ["fastlane@krausefx.com"]
  spec.summary       = Fastlane::DESCRIPTION
  spec.description   = Fastlane::DESCRIPTION
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"
  spec.metadata      = {
    "docs_url" => "https://docs.fastlane.tools"
  }

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir.glob("*/lib/**/*", File::FNM_DOTMATCH) + Dir["fastlane/swift/**/*"] + Dir["bin/*"] + Dir["*/README.md"] + %w(README.md LICENSE .yardopts) - Dir["fastlane/lib/fastlane/actions/device_grid/assets/*"] - Dir["fastlane/lib/fastlane/actions/docs/assets/*"]
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = Dir["*/lib"]

  spec.add_dependency('slack-notifier', '>= 2.0.0', '< 3.0.0') # Slack notifications
  spec.add_dependency('xcodeproj', '>= 1.8.1', '< 2.0.0') # Modify Xcode projects
  spec.add_dependency('xcpretty', '~> 0.3.0') # prettify xcodebuild output
  spec.add_dependency('terminal-notifier', '>= 2.0.0', '< 3.0.0') # macOS notifications
  spec.add_dependency('terminal-table', '>= 1.4.5', '< 2.0.0') # Actions documentation
  spec.add_dependency('plist', '>= 3.1.0', '< 4.0.0') # Needed for set_build_number_repository and get_info_plist_value actions
  spec.add_dependency('CFPropertyList', '>= 2.3', '< 4.0.0') # Needed to be able to read binary plist format
  spec.add_dependency('addressable', '>= 2.3', '< 3.0.0') # Support for URI templates
  spec.add_dependency('multipart-post', '~> 2.0.0') # Needed for uploading builds to appetize
  spec.add_dependency('word_wrap', '~> 1.0.0') # to add line breaks for tables with long strings

  spec.add_dependency('public_suffix', '~> 2.0.0') # https://github.com/fastlane/fastlane/issues/10162

  # TTY dependencies
  spec.add_dependency('tty-screen', '>= 0.6.3', '< 1.0.0') # detect the terminal width
  spec.add_dependency('tty-spinner', '>= 0.8.0', '< 1.0.0') # loading indicators

  spec.add_dependency('babosa', '>= 1.0.2', "< 2.0.0")
  spec.add_dependency('colored') # colored terminal output
  spec.add_dependency('commander-fastlane', '>= 4.4.6', '< 5.0.0') # CLI parser
  spec.add_dependency('excon', '>= 0.45.0', '< 1.0.0') # Great HTTP Client
  spec.add_dependency('faraday-cookie_jar', '~> 0.0.6')
  spec.add_dependency('fastimage', '>= 2.1.0', '< 3.0.0') # fetch the image sizes from the screenshots
  spec.add_dependency('gh_inspector', '>= 1.1.2', '< 2.0.0') # search for issues on GitHub when something goes wrong
  spec.add_dependency('highline', '>= 1.7.2', '< 2.0.0') # user inputs (e.g. passwords)
  spec.add_dependency('json', '< 3.0.0') # Because sometimes it's just not installed
  spec.add_dependency('mini_magick', '>= 4.9.4', '< 5.0.0') # To open, edit and export PSD files
  spec.add_dependency('multi_xml', '~> 0.5')
  spec.add_dependency('rubyzip', '>= 1.2.2', '< 2.0.0') # fix swift/ipa in gym
  spec.add_dependency('security', '= 0.1.3') # macOS Keychain manager, a dead project, no updates expected
  spec.add_dependency('xcpretty-travis-formatter', '>= 0.0.3')
  spec.add_dependency('dotenv', '>= 2.1.1', '< 3.0.0')
  spec.add_dependency('bundler', '>= 1.12.0', '< 3.0.0') # Used for fastlane plugins
  spec.add_dependency('faraday', '~> 0.9') # Used for deploygate, hockey and testfairy actions
  spec.add_dependency('faraday_middleware', '~> 0.9') # same as faraday
  spec.add_dependency('simctl', '~> 1.6.3') # Used for querying and interacting with iOS simulators
  spec.add_dependency('jwt', '~> 2.1.0') # Used for generating authentication tokens for AppStore connect api

  # The Google API Client gem is *not* API stable between minor versions - hence the specific version locking here.
  # If you upgrade this gem, make sure to upgrade the users of it as well.
  spec.add_dependency('google-api-client', '>= 0.21.2', '< 0.24.0') # Google API Client to access Play Publishing API
  spec.add_dependency('google-cloud-storage', '>= 1.15.0', '< 2.0.0') # Access Google Cloud Storage for match

  spec.add_dependency('emoji_regex', '>= 0.1', '< 2.0') # Used to scan for Emoji in the changelog

  # Development only
  spec.add_development_dependency('rake', '< 12')
  spec.add_development_dependency('rspec', '~> 3.5.0')
  spec.add_development_dependency('rspec_junit_formatter', '~> 0.2.3')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('pry-byebug')
  spec.add_development_dependency('pry-rescue')
  spec.add_development_dependency('pry-stack_explorer')
  spec.add_development_dependency('yard', '~> 0.9.11')
  spec.add_development_dependency('webmock', '~> 2.3.2')
  spec.add_development_dependency('coveralls', '~> 0.8.13')
  spec.add_development_dependency('rubocop', Fastlane::RUBOCOP_REQUIREMENT)
  spec.add_development_dependency('rubocop-require_tools', '>= 0.1.2')
  spec.add_development_dependency('rb-readline') # https://github.com/deivid-rodriguez/byebug/issues/289#issuecomment-251383465
  spec.add_development_dependency('rest-client', '>= 1.8.0')
  spec.add_development_dependency('fakefs', '~> 0.8.1')
  spec.add_development_dependency('sinatra', '~> 1.4.8')
  spec.add_development_dependency('xcov', '~> 1.4.1') # Used for xcov's parameters generation: https://github.com/fastlane/fastlane/pull/12416
  spec.add_development_dependency('climate_control', '~> 0.2.0')
end
