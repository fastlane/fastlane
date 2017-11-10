module Fastlane
  module Actions
    require 'fastlane/actions/pem'
    class RenewPushCertificateAction < PemAction

      def self.run(config)
        UI.message "Making sure a valid push profile is active and creating a new one if needed using pem"
        super.run(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Makes sure a valid push profile is active and creates a new one if needed (via pem)"
      end
    end
  end
end
