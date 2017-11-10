module Fastlane
  module Actions
    require 'fastlane/actions/deliver'
    class SubmitBuildToAppStoreAction < DeliverAction
      def self.run(config)
        UI.message "Uploading metadata and binary to iTunes Connect using deliver"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload metadata and binary to iTunes Connect (via deliver)"
      end
    end
  end
end
