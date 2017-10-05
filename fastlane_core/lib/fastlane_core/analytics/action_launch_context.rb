require 'fastlane_core/helper'

module FastlaneCore
  class ActionLaunchContext
    attr_accessor :action_name
    attr_accessor :p_hash
    attr_accessor :platform

    def initialize(action_name: nil, p_hash: nil, platform: nil)
      @action_name = action_name
      @p_hash = p_hash
      @platform = platform
    end
  end
end
