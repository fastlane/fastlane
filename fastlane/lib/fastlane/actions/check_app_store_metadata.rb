module Fastlane
  module Actions
    require 'fastlane/actions/precheck'
    class CheckAppStoreMetadataAction < PrecheckAction

      def self.run(config)
        UI.message "Checking App Store metadata using precheck"
        super.run(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Check your app using a community driven set of App Store review rules to avoid being rejected (via precheck)"
      end
    end
  end
end
