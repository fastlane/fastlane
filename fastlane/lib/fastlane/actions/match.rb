module Fastlane
  module Actions
    require 'fastlane/actions/synchronize_provisioning'
    class MatchAction < SynchronizeProvisioningAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `synchronize_provisioning` action"
      end
    end
  end
end
