module FastlaneCore
  class ActionLaunchContext < AnalyticsContext
    attr_accessor :action_name
    attr_accessor :fastlane_version
    attr_accessor :install_method
    attr_accessor :operating_system
    attr_accessor :operating_system_version
    attr_accessor :ide_version
    attr_accessor :ci
    attr_accessor :fastfile
    attr_accessor :fastfile_id
    attr_accessor :platform
    attr_accessor :ruby_version
  end
end
