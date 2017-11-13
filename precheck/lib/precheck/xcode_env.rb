module Precheck
  # Xcode specific code that's being used to verify
  # Xcode project settings
  class XcodeEnv
    class << self
      def project_path
        ENV["PROJECT_FILE_PATH"]
      end

      def project_name
        ENV["PROJECT_NAME"]
      end

      def info_plist
        ENV["INFOPLIST_PATH"]
      end
    end
  end
end
