source "https://rubygems.org"

gem "xcode-install", ">= 2.0.10" # needed for running xcode-install related tests

gem "danger", ">= 4.2.1", "< 5.0.0"
gem "danger-junit", ">= 0.7.3", "< 1.0.0"
gem "danger-mention", ">= 0.4.0", "< 1.0.0"

gemspec path: "."

plugins_path = File.join(File.expand_path("..", __FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding)
