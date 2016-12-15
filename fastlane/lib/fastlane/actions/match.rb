module Fastlane
  module Actions
    class MatchAction < Action
      def self.run(params)
        require 'match'

        params.load_configuration_file("Matchfile")
        Match::Runner.new.run(params)

        define_profile_type(params)
      end

      def self.define_profile_type(values)
        profile_type = "app-store"
        profile_type = "ad-hoc" if values[:type] == 'adhoc'
        profile_type = "development" if values[:type] == 'development'
        profile_type = "enterprise" if values[:type] == 'enterprise'

        UI.message("Setting Provisioning Profile type to '#{profile_type}'")

        Actions.lane_context[SharedValues::SIGH_PROFILE_TYPE] = profile_type
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Easily sync your certificates and profiles across your team using git"
      end

      def self.details
        "More details https://github.com/fastlane/fastlane/tree/master/match"
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

      def self.example_code
        [
          'match(type: "appstore", app_identifier: "tools.fastlane.app")',
          'match(type: "development", readonly: true)',
          'match(app_identifier: ["tools.fastlane.app", "tools.fastlane.sleepy"])'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
