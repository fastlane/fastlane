module Fastlane
  module Actions
    require 'fastlane/actions/produce'
    class CreateItunesConnectAppAction < ProduceAction

      def self.run(config)
        UI.message "Creating a new app using produce"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Creates a new app on iTunes Connect and the Apple Developer Portal (via produce)"
      end
    end
  end
end
