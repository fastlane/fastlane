module Fastlane
  module Actions
    require 'fastlane/actions/get_provisioning_profile'
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
