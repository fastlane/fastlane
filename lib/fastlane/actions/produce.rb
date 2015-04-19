module Fastlane
  module Actions
    module SharedValues
      PRODUCE_APPLE_ID = :PRODUCE_APPLE_ID
    end

    class ProduceAction < Action
      def self.run(params)
        require 'produce'

        raise 'Parameter of produce must be a hash'.red unless params.is_a?(Hash)

        params.each do |key, value|
          ENV[key.to_s.upcase] = value.to_s
        end

        return if Helper.test?

        FastlaneCore::UpdateChecker.start_looking_for_update('produce') unless Helper.is_test?

        begin
          Dir.chdir(FastlaneFolder.path || Dir.pwd) do
            # This should be executed in the fastlane folder

            CredentialsManager::PasswordManager.shared_manager(ENV['PRODUCE_USERNAME']) if ENV['PRODUCE_USERNAME']
            Produce::Config.shared_config # to ask for missing information right in the beginning

            apple_id = Produce::Manager.start_producing.to_s

            Actions.lane_context[SharedValues::PRODUCE_APPLE_ID] = apple_id
            ENV['PRODUCE_APPLE_ID'] = apple_id
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('produce', Produce::VERSION)
        end
      end

      def self.description
        "Makes sure the given app identifier is created on the Dev Portal"
      end

      def details
        [
          'For more information about produce, visit its GitHub page:',
          'https://github.com/KrauseFx/produce'
        ].join(' ')
      end

      def self.available_options
        [
          ['produce_app_identifier', 'The App Identifier of your app', 'PRODUCE_APP_IDENTIFIER'],
          ['produce_app_name', 'The name of your app', 'PRODUCE_APP_NAME'],
          ['produce_language', 'The app\'s default language', 'PRODUCE_LANGUAGE'],
          ['produce_version', 'The initial version of your app', 'PRODUCE_VERSION'],
          ['produce_sku', 'The SKU number of the app if it gets created', 'PRODUCE_SKU'],
          ['produce_team_name', 'optional: the name of your team', 'PRODUCE_TEAM_NAME'],
          ['produce_team_id', 'optional: the ID of your team', 'PRODUCE_TEAM_ID'],
          ['produce_username', 'optional: your Apple ID', 'PRODUCE_USERNAME'],
          ['skip_itc', 'Skip the creation on iTunes Connect', 'PRODUCE_SKIP_ITC'],
          ['skip_devcenter', 'Skip the creation on the Apple Developer Portal', 'PRODUCE_SKIP_DEVCENTER']
        ]
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
    end
  end
end
