module Fastlane
  module Actions
    module SharedValues
      PRODUCE_APPLE_ID = :PRODUCE_APPLE_ID
    end

    class CreateAppOnlineAction < Action
      def self.run(params)
        require 'produce'

        return if Helper.test?

        Produce.config = params # we alread have the finished config

        Dir.chdir(FastlaneCore::FastlaneFolder.path || Dir.pwd) do
          # This should be executed in the fastlane folder
          apple_id = Produce::Manager.start_producing.to_s

          Actions.lane_context[SharedValues::PRODUCE_APPLE_ID] = apple_id
          ENV['PRODUCE_APPLE_ID'] = apple_id
        end
      end

      def self.description
        "Creates the given application on iTC and the Dev Portal (via _produce_)"
      end

      def self.details
        [
          "Create new apps on iTunes Connect and Apple Developer Portal via _produce_.",
          "If the app already exists, `create_app_online` will not do anything.",
          "For more information about _produce_, visit its documentation page: [https://docs.fastlane.tools/actions/produce/](https://docs.fastlane.tools/actions/produce/)."
        ].join("\n")
      end

      def self.available_options
        require 'produce'
        Produce::Options.available_options
      end

      def self.output
        [
          ['PRODUCE_APPLE_ID', 'The Apple ID of the newly created app. You probably need it for `deliver`']
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'create_app_online(
            username: "felix@krausefx.com",
            app_identifier: "com.krausefx.app",
            app_name: "MyApp",
            language: "English",
            app_version: "1.0",
            sku: "123",
            team_name: "SunApps GmbH" # Only necessary when in multiple teams.
          )',
          'produce   # alias for "create_app_online"'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
