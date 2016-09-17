module Fastlane
  module Actions
    class PutsAction < Action
      def self.run(params)
        UI.message params.join(' ')
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

      # We don't want to show this as step
      def self.step_text
        nil
      end
    end
  end
end
