module Fastlane
  module Actions
    class RubocopAction < Action
      def self.run(params)
        sh "bundle exec rubocop -D"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Runs the code style checks"
      end

      def self.available_options
        []
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
