module Fastlane
  module Actions
    require_relative 'upload_to_app_store'
    class AppstoreAction < UploadToAppStoreAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `upload_to_app_store` action"
      end
    end
  end
end
