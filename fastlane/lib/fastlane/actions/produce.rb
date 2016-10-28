module Fastlane
  module Actions
    module SharedValues
      PRODUCE_APPLE_ID = :PRODUCE_APPLE_ID
    end

    class ProduceAction < Action
      def self.run(params)
        require 'produce'

        return if Helper.test?

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('produce')
          Produce.config = params # we alread have the finished config

          Dir.chdir(FastlaneCore::FastlaneFolder.path || Dir.pwd) do
            # This should be executed in the fastlane folder
            apple_id = Produce::Manager.start_producing.to_s

            Actions.lane_context[SharedValues::PRODUCE_APPLE_ID] = apple_id
            ENV['PRODUCE_APPLE_ID'] = apple_id
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('produce', Produce::VERSION)
        end
      end

      def self.description
        "Creates the given application on iTC and the Dev Portal if necessary"
      end

      def details
        [
          'Create new apps on iTunes Connect and Apple Developer Portal. If the app already exists, `produce` will not do anything.',
          'For more information about produce, visit its GitHub page:',
          'https://github.com/fastlane/fastlane/tree/master/produce'
        ].join(' ')
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
          'produce(
            username: "felix@krausefx.com",
            app_identifier: "com.krausefx.app",
            app_name: "MyApp",
            language: "English",
            app_version: "1.0",
            sku: "123",
            team_name: "SunApps GmbH" # Only necessary when in multiple teams.
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
