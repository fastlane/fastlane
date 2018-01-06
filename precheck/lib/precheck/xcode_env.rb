module Precheck
  # Xcode specific code that's being used to verify
  # Xcode project settings
  class XcodeEnv
    class << self
      def run_as_build_phase?
        return true if ENV["PROJECT_FILE_PATH"].to_s.length > 0 &&
                       ENV["TARGET_NAME"].to_s.length > 0 &&
                       ENV["CONFIGURATION"].to_s.length > 0
        false
      end

      def project_path
        ENV["PROJECT_FILE_PATH"]
      end

      def target_name
        ENV["TARGET_NAME"]
      end

      def configuration
        ENV["CONFIGURATION"]
      end
    end
  end
end
