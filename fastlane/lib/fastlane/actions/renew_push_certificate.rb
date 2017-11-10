module Fastlane
  module Actions
    require 'fastlane/actions/pem'
    class RenewPushCertificateAction < PemAction
      def self.run(config)
        UI.message "Making sure a valid push profile is active and creating a new one if needed using pem"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Makes sure a valid push profile is active (via pem)"
      end
    end
  end
end
