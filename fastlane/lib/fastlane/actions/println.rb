module Fastlane
  module Actions
    require 'fastlane/actions/puts'
    class PrintlnAction < PutsAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `puts` action"
      end
    end
  end
end
