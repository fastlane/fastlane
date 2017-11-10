module Fastlane
  module Actions
    require 'fastlane/actions/deliver'
    class AppstoreAction < DeliverAction

      def self.run(config)
        UI.message "Uploading to the App Store using deliver"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the deliver action"
      end
    end
  end
end
