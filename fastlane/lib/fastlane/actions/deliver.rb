module Fastlane
  module Actions
    require 'fastlane/actions/upload_to_app_store'
    class DeliverAction < UploadToAppStoreAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `upload_to_app_store` action"
      end
    end
  end
end
