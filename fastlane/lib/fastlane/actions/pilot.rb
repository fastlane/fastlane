module Fastlane
  module Actions
    require 'fastlane/actions/upload_to_testflight'
    class PilotAction < UploadToTestflightAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `upload_to_testflight` action"
      end
    end
  end
end
