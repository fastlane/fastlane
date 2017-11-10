module Fastlane
  module Actions
    require 'fastlane/actions/supply'
    class UploadToPlayStoreAction < SupplyAction

      def self.run(config)
        UI.message "Uploading metadata, screenshots, and binaries to Google Play using supply"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload metadata, screenshots, and binaries to Google Play (via supply)"
      end
    end
  end
end
