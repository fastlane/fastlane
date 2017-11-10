module Fastlane
  module Actions
    require 'fastlane/actions/scan'
    class RunTestsAction < ScanAction
      def self.run(config)
        UI.message "Running tests of your app using scan"
        super(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Run tests of your iOS and Mac app (via scan)"
      end
    end
  end
end
