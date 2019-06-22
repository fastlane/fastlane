module Fastlane
  class ActionCollector
    def show_message
      UI.message("Sending Crash/Success information. Learn more at https://docs.fastlane.tools/#metrics")
      UI.message("No personal/sensitive data is sent. Only sharing the following:")
      UI.message(launches)
      UI.message(@error) if @error
      UI.message("This information is used to fix failing actions and improve integrations that are often used.")
      UI.message("You can disable this by adding `opt_out_usage` at the top of your Fastfile")
    end

    def determine_version(name)
      self.class.determine_version(name)
    end

    # e.g.
    #   :gym
    #   :xcversion
    #   "fastlane-plugin-my_plugin/xcversion"
    def self.determine_version(name)
      if name.to_s.include?(PluginManager.plugin_prefix)
        # That's an action from a plugin, we need to fetch its version number
        begin
          plugin_name = name.split("/").first.gsub(PluginManager.plugin_prefix, '')
          return Fastlane.const_get(plugin_name.fastlane_class)::VERSION
        rescue => ex
          UI.verbose(ex)
          return "undefined"
        end
      end

      return Fastlane::VERSION # that's the case for all built-in actions
    end
  end
end
