module Fastlane
  module Helper
    class XcodebuildFormatterHelper
      def self.xcbeautify_installed?
        return !FastlaneCore::Helper.which('xcbeautify').nil?
      end
    end
  end
end
