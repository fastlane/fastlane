require 'fastlane_core/helper'

module FastlaneCore
  class ActionLaunchContext
    UNKNOWN_P_HASH = 'unknown'

    attr_accessor :action_name
    attr_accessor :p_hash
    attr_accessor :platform

    def initialize(action_name: nil, p_hash: UNKNOWN_P_HASH, platform: nil)
      @action_name = action_name
      @p_hash = p_hash
      @platform = platform
    end

    def self.context_for_action_name(action_name, args: nil)
      app_id_guesser = FastlaneCore::AppIdentifierGuesser.new(args: args)
      return self.new(
        action_name: action_name,
        p_hash: app_id_guesser.p_hash,
        platform: app_id_guesser.platform
      )
    end

    def build_tool_version
      if platform == :android
        return 'android'
      else
        return "Xcode #{Helper.xcode_version}"
      end
    end
  end
end
