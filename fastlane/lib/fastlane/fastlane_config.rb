module Fastlane
  class FastlaneConfig
    def min_fastlane_version=(version)
      Actions::MinFastlaneVersionAction.run([version])
    end

    def default_platform=(platform)
      Actions::DefaultPlatformAction.run([platform])
    end
  end
end
