module Fastlane
  module Actions
    require_relative internal('fastlane/actions/gradle')
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
