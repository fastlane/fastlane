module Fastlane
  module Actions
    class SkipDocsAction < Action
      def self.run(params)
        ENV["FASTLANE_SKIP_DOCS"] = "1"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Skip the creation of the fastlane/README.md file when running fastlane"
      end

      def self.available_options
      end

      def self.output
      end

      def self.return_value
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
