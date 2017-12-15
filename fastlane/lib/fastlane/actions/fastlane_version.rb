require "fastlane/actions/min_fastlane_version"

module Fastlane
  module Actions
    class FastlaneVersionAction < MinFastlaneVersionAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `min_fastlane_version` action"
      end
    end
  end
end
