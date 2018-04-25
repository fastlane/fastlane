module Fastlane
  module Actions
    class SkipDocsAction < Action
      def self.run(params)
        ENV["FASTLANE_SKIP_DOCS"] = "1"
      end

      def self.step_text
        nil
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

      def self.details
        "Tell _fastlane_ to not automatically create a `fastlane/README.md` when running _fastlane_. You can always trigger the creation of this file manually by running `fastlane docs`."
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'skip_docs'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
