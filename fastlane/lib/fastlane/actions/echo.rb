module Fastlane
  module Actions
    require 'fastlane/actions/puts'
    class EchoAction < PutsAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `puts` action"
      end
    end
  end
end
