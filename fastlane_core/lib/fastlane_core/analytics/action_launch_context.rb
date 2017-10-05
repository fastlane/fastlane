require 'fastlane_core/helper'

module FastlaneCore
  class ActionLaunchContext < AnalyticsContext
    attr_accessor :action_name
    attr_accessor :p_hash
  end
end
