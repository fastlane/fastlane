module Fastlane
  module Actions
    require 'fastlane/actions/gym'
    class GymAction < BuildAppAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `build_app` action"
      end
    end
  end
end
