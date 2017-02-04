source "https://rubygems.org"

gem "xcode-install", ">= 2.0.10"
gemspec path: "."

plugins_path = File.join(File.expand_path("..", __FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding)
