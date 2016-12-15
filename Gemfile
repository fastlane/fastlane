source "https://rubygems.org"

# Needed for CI
gem "danger", "~> 0.10"

# Local fastlane, important to be included using `gemspec`, as this will
# also include development dependencies
gemspec path: File.join(Dir.pwd, "fastlane")

plugins_path = File.join(Dir.pwd, 'fastlane', 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)

# Use the local copy of all tools
require "fastlane/tools.rb"
tools = Fastlane::TOOLS + [:fastlane_core, :credentials_manager]
tools.each do |tool_name|
  next if tool_name == :fastlane
  gem tool_name.to_s, path: File.join(Dir.pwd, tool_name.to_s)
end
