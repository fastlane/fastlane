source("https://rubygems.org")

gem "xcode-install", ">= 2.6.7" # needed for running xcode-install related tests

gem "danger", "~> 8.0"
gem "danger-junit", "~> 1.0"
gem "ox", "2.13.2"

gemspec(path: ".")

plugins_path = File.join(File.expand_path("..", __FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path)
