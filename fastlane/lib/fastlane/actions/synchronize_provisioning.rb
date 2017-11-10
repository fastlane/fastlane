module Fastlane
  module Actions
    require 'fastlane/actions/match'
    class SynchronizeProvisioningAction < MatchAction
      def self.run(config)
        UI.message "Syncronizing certificates and profiles using match"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Easily sync your certificates and profiles across your team (via match)"
      end
    end
  end
end
