module Fastlane
  module Helper
    class XcodebuildFormatterHelper
      def self.xcbeautify_installed?
        return `which xcbeautify`.include?("xcbeautify")
      end
    end
  end
end
