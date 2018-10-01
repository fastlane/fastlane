module Fastlane
  module Actions
    require_relative 'upload_to_testflight'
    class TestflightAction < UploadToTestflightAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `upload_to_testflight` action"
      end
    end
  end
end
