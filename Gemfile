source("https://rubygems.org")

# Needed for the Fastlane::RUBOCOP_REQUIREMENT below
require_relative "fastlane/lib/fastlane/version.rb"

# Please keep all gems and their comments together without empty lines, so RuboCop can sort them alphabetically.

# Allows fine-grained control of environment variables.
gem "climate_control", "~> 0.2.0"
# A tool for integrating Coveralls.io with Ruby apps.
gem "coveralls", "~> 0.8.13"
# Automates code review chores.
gem "danger", "~> 8.0"
# Plugin for Danger that reports JUnit test results.
gem "danger-junit", "~> 1.0"
# A fake filesystem.
# Version 3.0+ requires Ruby >=3.0, while fastlane uses a `required_ruby_version` of `>= 2.7`.
gem "fakefs", ['>= 1.8', '< 3.0']
# for file uploads with Faraday
gem "mime-types", ['>= 1.16', '< 4.0']
# standard library for OpenSSL has affected versions (unable to get certificate CRL) - ruby/openssl/issues/949
# We block affected versions here so a patched gem version will be used regardless of Ruby version.
gem "openssl",
    ">= 3.1.2",
    "!= 3.2.0",
    "!= 3.2.1",
    "!= 3.3.0"
# Fast XML parser and object marshaller.
gem "ox", "~> 2.14"
# Provides an interactive debugging environment for Ruby.
gem "pry"
# A plugin for pry that adds step-by-step debugging and stack navigation.
gem "pry-byebug"
# A pry rescue environment to automatically open pry when a test fails.
gem "pry-rescue"
# A plugin for pry that enables exploring the call stack.
gem "pry-stack_explorer"
# public_suffix >= 6.0 requires Ruby >= 3.0, while fastlane uses a `required_ruby_version` of `>= 2.7`.
gem "public_suffix", "< 6.0"
# A simple task automation tool.
gem "rake"
# A readline implementation in Ruby
# See: https://github.com/deivid-rodriguez/byebug/issues/289#issuecomment-251383465
gem "rb-readline"
# Behavior-driven testing tool for Ruby.
gem "rspec", "~> 3.10"
# Formatter for RSpec to generate JUnit compatible reports.
gem "rspec_junit_formatter", "~> 0.4.1"
# A Ruby static code analyzer and formatter.
gem "rubocop", Fastlane::RUBOCOP_REQUIREMENT
# A collection of RuboCop cops for performance optimizations.
gem "rubocop-performance"
# A RuboCop extension focused on enforcing tools.
gem "rubocop-require_tools"
# Used to mock servers.
gem "sinatra", [">= 2.2.3", "< 3.0"]
# A library for stubbing and setting expectations on HTTP requests.
gem "webmock", "~> 3.18"
# Needed for running xcode-install related tests.
gem "xcode-install", ">= 2.6.7"
# Used for xcov's parameters generation: https://github.com/fastlane/fastlane/pull/12416
gem "xcov", "~> 1.9.0"
# A documentation generation tool for Ruby.
gem "yard", "~> 0.9.11"

gemspec(path: ".")

eval_gemfile("fastlane/Pluginfile")
