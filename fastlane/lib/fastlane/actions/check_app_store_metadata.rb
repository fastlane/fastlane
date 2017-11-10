module Fastlane
  module Actions
    require 'fastlane/actions/precheck'
    class CheckAppStoreMetadataAction < PrecheckAction
      def self.run(config)
        UI.message "Checking App Store metadata using precheck"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Check your app's metadata to avoid being rejected (via precheck)"
      end
    end
  end
end
