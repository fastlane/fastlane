module Fastlane
  module Actions
    def self.ignore_cocoapods_path(all_xcodeproj_paths)
      all_xcodeproj_paths.reject { |path| %r{/Pods/.*.xcodeproj} =~ path }
    end
  end
end
