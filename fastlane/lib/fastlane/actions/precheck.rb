module Fastlane
  module Actions
    module SharedValues
    end

    class PrecheckAction < Action
      def self.run(config)
        require 'precheck'
        Precheck.config = config
        return Precheck::Runner.new.run
      end

      def self.description
        "Check your app's metadata before you submit your app to review using _precheck_"
      end

      def self.details
        "More information: https://fastlane.tools/precheck"
      end

      def self.available_options
        require 'precheck/options'
        Precheck::Options.available_options
      end

      def self.return_value
        return "true if precheck passes, else, false"
      end

      def self.authors
        ["taquitos"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'precheck(
            negative_apple_sentiment(level: :skip), # Set to skip to not run the `negative_apple_sentiment` rule
            curse_words(level: :warn) # Set to warn to only warn on curse word check failures
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
