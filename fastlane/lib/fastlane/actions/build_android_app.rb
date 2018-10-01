module Fastlane
  module Actions
    require_relative 'gradle'
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
