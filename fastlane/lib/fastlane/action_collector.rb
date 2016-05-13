module Fastlane
  class ActionCollector < FastlaneCore::ToolCollector
    def is_official?(name)
      return true if name == :lane_switch
      Actions.get_all_official_actions.include? name
    end

    def show_message
      UI.message("Sending Crash/Success information. More information on: https://github.com/fastlane/enhancer")
      UI.message("No personal/sensitive data is sent. Only sharing the following:")
      UI.message(launches)
      UI.message(@error) if @error
      UI.message("This information is used to fix failing actions and improve integrations that are often used.")
      UI.message("You can disable this by adding `opt_out_usage` to your Fastfile")
    end

    def determine_version(name)
      super(name) || Fastlane::VERSION
    end
  end
end
