source "https://rubygems.org"

gem "xcode-install", git: "https://github.com/KrauseFx/xcode-install.git", branch: "update-for-mono-gem"
gemspec path: "."

plugins_path = File.join(File.expand_path("..", __FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding)
