module Fastlane
  module Helper
    class XcodebuildFormatterHelper
      def self.xcbeautify_installed?
        return !!FastlaneCore::Helper.which('xcbeautify')
      end
    end
  end
end
