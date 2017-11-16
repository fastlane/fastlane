module Fastlane
  module Actions
    require 'fastlane/actions/run_tests'
    class ScanAction < RunTestsAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `run_tests` action"
      end
    end
  end
end
