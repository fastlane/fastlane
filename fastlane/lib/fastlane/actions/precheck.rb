module Fastlane
  module Actions
    require 'fastlane/actions/check_app_store_metadata'
    class PrecheckAction < CheckAppStoreMetadataAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `check_app_store_metadata` action"
      end
    end
  end
end
