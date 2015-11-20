module Fastlane
  module Actions
    class SwiftlintAction < Action
      def self.run(params)
        raise "You have to install swiftlint using `brew install swiftlint`".red if `which swiftlint`.to_s.length == 0
        Actions.sh("swiftlint")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Run swift code validation using SwiftLint"
      end

      def self.details
      end

      def self.available_options
        [
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
