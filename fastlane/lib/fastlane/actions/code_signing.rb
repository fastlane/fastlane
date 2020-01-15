module Fastlane
  module Actions
    require 'fastlane/actions/automatic_code_signing'
    class CodeSigningAction < AutomaticCodeSigningAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `automatic_code_signing` action"
      end
    end
  end
end
