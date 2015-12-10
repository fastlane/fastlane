module Fastlane
  module Actions
    class MatchAction < Action
      def self.run(params)
        require 'match'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('match') unless Helper.is_test?

          params.load_configuration_file("Matchfile")
          Match::Runner.new.run(params)
        ensure
          FastlaneCore::UpdateChecker.show_update_status('match', Match::VERSION)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Easily sync your certificates and profiles across your team using git"
      end

      def self.details
        "More details https://github.com/fastlane/match"
      end

      def self.available_options
        require 'match'
        Match::Options.available_options
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
