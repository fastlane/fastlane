module Fastlane
  module Actions
    require_relative 'get_provisioning_profile'
    class SighAction < GetProvisioningProfileAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `get_provisioning_profile` action"
      end
    end
  end
end
