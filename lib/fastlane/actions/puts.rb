module Fastlane
  module Actions
    class PutsAction < Action
      def self.run(params)
        Helper.log.info params.join(' ')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Prints out the given text"
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end