require 'fastlane_core/tool_collector'

module Fastlane
  class ActionCollector < FastlaneCore::ToolCollector
    # Is this an official fastlane action, that is bundled with fastlane?
    def is_official?(name)
      return true if name == :lane_switch
      Actions.get_all_official_actions.include?(name)
    end

    def name_to_track(name)
      return name if is_official?(name)

      Fastlane.plugin_manager.plugin_references.each do |plugin_name, value|
        return "#{plugin_name}/#{name}" if value[:actions].include?(name)
      end

      return nil
    end

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
      result = super(name)
      return result if result

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
