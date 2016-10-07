# Workaround, since deploygate.rb from shenzhen includes the code for commander
def command(_param)
end

module Fastlane
  module Actions
    module SharedValues
      DEPLOYGATE_URL = :DEPLOYGATE_URL
      DEPLOYGATE_REVISION = :DEPLOYGATE_REVISION # auto increment revision number
      DEPLOYGATE_APP_INFO = :DEPLOYGATE_APP_INFO # contains app revision, bundle identifier, etc.
    end

    class DeploygateAction < Action
      DEPLOYGATE_URL_BASE = 'https://deploygate.com'

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.run(options)
        require 'shenzhen'
        require 'shenzhen/plugins/deploygate'

        # Available options: https://deploygate.com/docs/api
        UI.success('Starting with ipa upload to DeployGate... this could take some time ⏳')

        client = Shenzhen::Plugins::DeployGate::Client.new(
          options[:api_token],
          options[:user]
        )

        return options[:ipa] if Helper.test?

        filter = [:message, :distribution_key, :release_note]
        response = client.upload_build(
          options[:ipa],
          options.values.select do |key, _|
            filter.include? key
          end
        )
        if parse_response(response)
          UI.message("DeployGate URL: #{Actions.lane_context[SharedValues::DEPLOYGATE_URL]}")
          UI.success("Build successfully uploaded to DeployGate as revision \##{Actions.lane_context[SharedValues::DEPLOYGATE_REVISION]}!")
        else
          UI.user_error!("Error when trying to upload ipa to DeployGate")
        end
      end

      def self.parse_response(response)
        if response.body && response.body.key?('error')

          if response.body['error']
            UI.error("Error uploading to DeployGate: #{response.body['message']}")
            help_message(response)
            return
          else
            res = response.body['results']
            url = DEPLOYGATE_URL_BASE + res['path']

            Actions.lane_context[SharedValues::DEPLOYGATE_URL] = url
            Actions.lane_context[SharedValues::DEPLOYGATE_REVISION] = res['revision']
            Actions.lane_context[SharedValues::DEPLOYGATE_APP_INFO] = res
          end
        else
          UI.error("Error uploading to DeployGate: #{response.body}")
          return
        end
        true
      end
      private_class_method :parse_response

      def self.help_message(response)
        message =
          case response.body['message']
          when 'you are not authenticated'
            'Invalid API Token specified.'
          when 'application create error: permit'
            'Access denied: May be trying to upload to wrong user or updating app you join as a tester?'
          when 'application create error: limit'
            'Plan limit: You have reached to the limit of current plan or your plan was expired.'
          end
        UI.error(message) if message
      end
      private_class_method :help_message

      def self.description
        "Upload a new build to [DeployGate](https://deploygate.com/)"
      end

      def self.details
        [
          "You can retrieve your username and API token on [your settings page](https://deploygate.com/settings)",
          "More information about the available options can be found in the [DeployGate Push API document](https://deploygate.com/docs/api)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "DEPLOYGATE_API_TOKEN",
                                       description: "Deploygate API Token",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API Token for DeployGate given, pass using `api_token: 'token'`") unless value.to_s.length > 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :user,
                                       env_name: "DEPLOYGATE_USER",
                                       description: "Target username or organization name",
                                       verify_block: proc do |value|
                                         UI.user_error!("No User for app given, pass using `user: 'user'`") unless value.to_s.length > 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "DEPLOYGATE_IPA_PATH",
                                       description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "DEPLOYGATE_MESSAGE",
                                       description: "Release Notes",
                                       default_value: "No changelog provided"),
          FastlaneCore::ConfigItem.new(key: :distribution_key,
                                       optional: true,
                                       env_name: "DEPLOYGATE_DISTRIBUTION_KEY",
                                       description: "Target Distribution Key"),
          FastlaneCore::ConfigItem.new(key: :release_note,
                                       optional: true,
                                       env_name: "DEPLOYGATE_RELEASE_NOTE",
                                       description: "Release note for distribution page")
        ]
      end

      def self.output
        [
          ['DEPLOYGATE_URL', 'URL of the newly uploaded build'],
          ['DEPLOYGATE_REVISION', 'auto incremented revision number'],
          ['DEPLOYGATE_APP_INFO', 'Contains app revision, bundle identifier, etc.']
        ]
      end

      def self.example_code
        [
          'deploygate(
            api_token: "...",
            user: "target username or organization name",
            ipa: "./ipa_file.ipa",
            message: "Build #{lane_context[SharedValues::BUILD_NUMBER]}",
            distribution_key: "(Optional) Target Distribution Key"
          )'
        ]
      end

      def self.category
        :beta
      end

      def self.author
        "tnj"
      end
    end
  end
end
