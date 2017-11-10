module Fastlane
  module Actions
    require 'fastlane/actions/pilot'
    class TestflightAction < PilotAction
      def self.run(config)
        UI.message "Uploading to TestFlight using pilot"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the pilot action"
      end
    end
  end
end
