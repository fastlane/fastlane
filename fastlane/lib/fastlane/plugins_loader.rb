module Fastlane
  class PluginsLoader
    # Iterate over all available plugins
    # which follow the naming convention
    #   fastlane_[plugin_name]
    # This will make sure to load the action
    # and all its helpers
    def self.load_plugins
      Gem::Specification.all.to_hash.find_all do |gem_name, v| 
        gem_name.start_with?("fastlane_") && gem_name != "fastlane_core"
      end.each do |gem_name, current_gem|
        load_plugin(gem_name)
      end
    end

    # Actually imports the action and its helpers
    # `gem_name` must start with `fastlane_`
    def self.load_plugin(gem_name)
      action_name = gem_name.gsub("fastlane_", "")

      require gem_name
      require File.join(gem_name, "actions", action_name)

      begin
        require File.join(gem_name, "helper", "#{action_name}_helper")
      rescue LoadError
        # Since helpers are optional, we don't show an error message here
      end
    rescue => ex
      UI.error("Error loading plugin '#{gem_name}': #{ex.to_s}")
      UI.error("Make sure the plugin has a properly implemented action")
    end
  end
end
