module Fastlane
  module Actions
    require 'fastlane/actions/generate_provisioning_profile'
    class SighAction < GenerateProvisioningProfileAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `generate_provisioning_profile` action"
      end
    end
  end
end
