module Fastlane
  module Actions
    class GetManagedPlayStorePublishingRightsAction < Action
      def self.run(params)
        unless params[:json_key] || params[:json_key_data]
          UI.important("To not be asked about this value, you can specify it using 'json_key'")
          json_key_path = UI.input("The service account json file used to authenticate with Google: ")
          json_key_path = File.expand_path(json_key_path)

          UI.user_error!("Could not find service account json file at path '#{json_key_path}'") unless File.exist?(json_key_path)
          params[:json_key] = json_key_path
        end

        FastlaneCore::PrintTable.print_values(
          config: params,
          mask_keys: [:json_key_data],
          title: "Summary for get_managed_play_store_publishing_rights"
        )

        if (keyfile = params[:json_key])
          json_key_data = File.open(keyfile, 'rb').read
        else
          json_key_data = params[:json_key_data]
        end

        # Login
        credentials = JSON.parse(json_key_data)
        callback_uri = 'https://fastlane.github.io/managed_google_play-callback/callback.html'
        uri = "https://play.google.com/apps/publish/delegatePrivateApp?service_account=#{credentials['client_email']}&continueUrl=#{URI.escape(callback_uri)}"

        UI.message("To obtain publishing rights for custom apps on Managed Play Store, open the following URL and log in:")
        UI.message("")
        UI.important(uri)
        UI.message("([Cmd/Ctrl] + [Left click] lets you open this URL in many consoles/terminals/shells)")
        UI.message("")
        UI.message("After successful login you will be redirected to a page which outputs some information that is required for usage of the `create_app_on_managed_play_store` action.")

        return uri
      end

      def self.description
        "Obtain publishing rights for custom apps on Managed Google Play Store"
      end

      def self.authors
        ["janpio"]
      end

      def self.return_value
        "An URI to obtain publishing rights for custom apps on Managed Play Store"
      end

      def self.details
        [
          'If you haven\'t done so before, start by following the first two steps of Googles ["Get started with custom app publishing"](https://developers.google.com/android/work/play/custom-app-api/get-started) -> ["Preliminary setup"](https://developers.google.com/android/work/play/custom-app-api/get-started#preliminary_setup) instructions:',
          '"[Enable the Google Play Custom App Publishing API](https://developers.google.com/android/work/play/custom-app-api/get-started#enable_the_google_play_custom_app_publishing_api)" and "[Create a service account](https://developers.google.com/android/work/play/custom-app-api/get-started#create_a_service_account)".',
          'You need the "service account\'s private key file" to continue.',
          'Run the action and supply the "private key file" to it as the `json_key` parameter. The command will output a URL to visit. After logging in you are redirected to a page that outputs your "Developer Account ID" - take note of that, you will need it to be able to use [`create_app_on_managed_play_store`](https://docs.fastlane.tools/actions/create_app_on_managed_play_store/).'
        ].join("\n")
      end

      def self.example_code
        [
          'get_managed_play_store_publishing_rights(
            json_key: "path/to/your/json/key/file"
          )
          # it is probably easier to execute this action directly in the command line:
          # $ fastlane run get_managed_play_store_publishing_rights'
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :json_key,
            env_name: "SUPPLY_JSON_KEY",
            short_option: "-j",
            conflicting_options: [:json_key_data],
            optional: true, # optional until it is possible specify either json_key OR json_key_data are required
            description: "The path to a file containing service account JSON, used to authenticate with Google",
            code_gen_sensitive: true,
            default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_file),
            default_value_dynamic: true,
            verify_block: proc do |value|
              UI.user_error!("Could not find service account json file at path '#{File.expand_path(value)}'") unless File.exist?(File.expand_path(value))
              UI.user_error!("'#{value}' doesn't seem to be a JSON file") unless FastlaneCore::Helper.json_file?(File.expand_path(value))
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :json_key_data,
            env_name: "SUPPLY_JSON_KEY_DATA",
            short_option: "-c",
            conflicting_options: [:json_key],
            optional: true,
            description: "The raw service account JSON data used to authenticate with Google",
            code_gen_sensitive: true,
            default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_data_raw),
            default_value_dynamic: true,
            verify_block: proc do |value|
              begin
                JSON.parse(value)
              rescue JSON::ParserError
                UI.user_error!("Could not parse service account json: JSON::ParseError")
              end
            end
          )

        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end

      def self.category
        :misc
      end
    end
  end
end
