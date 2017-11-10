module Fastlane
  module Actions
    require 'fastlane/actions/sigh'
    class GenerateProvisioningProfileAction < SighAction

      def self.run(config)
        UI.message "Generating a provisining profile via sigh"
        super.run(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generates a provisioning profile; stores the profile in the current folder (via sigh)"
      end
    end
  end
end
