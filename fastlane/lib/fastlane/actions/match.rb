module Fastlane
  module Actions
    require 'fastlane/actions/sync_code_signing'
    class MatchAction < SyncCodeSigningAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `sync_code_signing` action"
      end
    end
  end
end
