module Fastlane
  module Actions
    require 'fastlane/actions/gradle'
    class BuildAndroidAppAction < GradleAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `gradle` action"
      end
    end
  end
end
