module Fastlane
  module Actions
    require 'fastlane/actions/pilot'
    class UploadToTestflightAction < PilotAction
      def self.run(config)
        UI.message "Uploading a binary to TestFlight using pilot"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Uploads a new binary to Apple TestFlight (via pilot)"
      end
    end
  end
end
