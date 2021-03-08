source("https://rubygems.org")

gem "xcode-install", ">= 2.6.7" # needed for running xcode-install related tests

gem "danger", "~> 8.0"
gem "danger-junit", "~> 1.0"

# Locking this in until Ruby 2.4 is no longer officially supported by fastlane
gem "signet", "< 0.15.0"
gem "googleauth", "< 0.16.0"

gemspec(path: ".")

plugins_path = File.join(File.expand_path("..", __FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path)
