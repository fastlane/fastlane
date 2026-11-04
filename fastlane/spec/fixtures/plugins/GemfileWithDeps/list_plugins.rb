require "fastlane"

plugin_manager = Fastlane::PluginManager.new
puts("available: #{plugin_manager.available_plugins.join(',')}")
puts("required by dependency_with_plugins: #{plugin_manager.plugins_required_by('dependency_with_plugins').join(',')}")
