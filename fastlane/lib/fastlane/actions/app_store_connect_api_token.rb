module Fastlane
  module Actions
    module SharedValues
      APP_STORE_CONNECT_API_TOKEN = :APP_STORE_CONNECT_API_TOKEN
    end

    class AppStoreConnectApiTokenAction < Action
      def self.run(options)
        token_text = options[:token_text]
        token_filepath = options[:token_filepath]
        in_house = options[:in_house]
        set_spaceship_token = options[:set_spaceship_token]

        if token_text.nil?
          if token_filepath.nil?
            UI.user_error!(':token_text or :token_filepath is required')
          else
            token_text = File.read(File.expand_path(token_filepath))
          end
        end

        token_text = token_text.gsub(/\n/, '')

        token = {
          in_house: in_house,
          token_text: token_text
        }

        Actions.lane_context.set_sensitive(SharedValues::APP_STORE_CONNECT_API_TOKEN, token)

        Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(**token) if set_spaceship_token

        return token
      end

      def self.description
        'Load the App Store Connect API token to use in other fastlane tools and actions'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :token_text,
                                       env_name: 'APP_STORE_CONNECT_API_TOKEN_TOKEN_TEXT',
                                       description: 'The App Store Connect API JWT token text',
                                       optional: true,
                                       conflicting_options: [:token_filepath]),
          FastlaneCore::ConfigItem.new(key: :token_filepath,
                                       env_name: 'APP_STORE_CONNECT_API_TOKEN_TOKEN_FILEPATH',
                                       description: 'The path to JWT token file',
                                       optional: true,
                                       conflicting_options: [:token_text]),
          FastlaneCore::ConfigItem.new(key: :in_house,
                                       env_name: 'APP_STORE_CONNECT_API_TOKEN_IN_HOUSE',
                                       description: 'Is App Store or Enterprise (in house) team? App Store Connect API cannot determine this on its own (yet)',
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :set_spaceship_token,
                                       env_name: 'APP_STORE_CONNECT_API_TOKEN_SET_SPACESHIP_TOKEN',
                                       description: 'Authorizes all Spaceship::ConnectAPI requests by automatically setting Spaceship::ConnectAPI.token',
                                       type: Boolean,
                                       default_value: true)
        ]
      end

      def self.output
        [
          [
            'APP_STORE_CONNECT_API_TOKEN',
            'The App Store Connect API token information used for authorization requests. This hash can be passed directly into the :api_token options on other tools or into Spaceship::ConnectAPI::Token.create method'
          ]
        ]
      end

      def self.author
        ['AlesMMichalek']
      end

      def self.is_supported?(platform)
        [:ios, :mac, :tvos].include?(platform)
      end

      def self.details
        [
          'Load the App Store Connect API token to use in other fastlane tools and actions'
        ].join('\n')
      end

      def self.example_code
        [
          'app_store_connect_api_token(
             token_text: \'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEyM0FCQyJ9.eyJpc3MiOiJlY2VjZWNlYy0wMDAwLTExMTEtZmZmZi1hYWFhYWFhYWFhYWEiLCJpYXQiOjk0NjY4MTIwMCwiZXhwIjo5NDY2ODE5ODAsImF1ZCI6ImFwcHN0b3JlY29ubmVjdC12MSJ9.YRLlzEo52OpWGSyIzni29nWMCtuv_dP3V3bvtVN2Zl6jwppmcK3gWDrE34c-DCMTz3z4OEO43HOabzhjeQzeAw\'
           )',
          'app_store_connect_api_token(
             in_house: true,
             set_spaceship_token: false,
             token_filepath: \'api_token.jwt\'
           )'
        ]
      end

      def self.category
        :app_store_connect
      end
    end
  end
end
