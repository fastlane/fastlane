module Fastlane
  module Actions
    require 'fastlane/actions/create_itunes_connect_app'
    class ProduceAction < CreateItunesConnectAppAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `create_itunes_connect_app` action"
      end
    end
  end
end
