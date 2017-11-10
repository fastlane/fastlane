module Fastlane
  module Actions
    require 'fastlane/actions/sigh'
    class GenerateProvisioningProfileAction < SighAction
      def self.run(config)
        UI.message "Generating a provisining profile via sigh"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generates a provisioning profile (via sigh)"
      end
    end
  end
end
