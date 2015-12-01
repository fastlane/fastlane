module Fastlane
  module Actions
    class JazzyAction < Action
      def self.run(params)
        Actions.verify_gem!('jazzy')
        Actions.sh("jazzy")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generate docs using Jazzy"
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
