module Fastlane
  module Actions
    class GetManagedPlayStorePublishingRightsAction < Action
      def self.run(params)
        unless params[:json_key] || params[:json_key_data]
          UI.important("To not be asked about this value, you can specify it using 'json_key'")
          params[:json_key] = UI.input("The service account json file used to authenticate with Google: ")
        end

        FastlaneCore::PrintTable.print_values(
          config: params,
          mask_keys: [:json_key_data],
          title: "Summary for GetManagedPlayStorePublishingRights" # TODO
        )

        @keyfile = params[:json_key] # TODO: json_key_data as alternative

        # login
        credentials = JSON.parse(File.open(@keyfile, 'rb').read)
        # puts 'credentials: '+credentials.inspect
        # puts 'email: ' + credentials['client_email']

        callback_uri = 'https://janpio.github.io/fastlane-plugin-managed_google_play/callback.html'
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
        # Optional:
        "none yet"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :json_key,
            env_name: "SUPPLY_JSON_KEY", # TODO
            short_option: "-j",
            conflicting_options: [:json_key_data],
            optional: true, # this shouldn't be optional but is until I find out how json_key OR json_key_data can be required
            description: "The path to a file containing service account JSON, used to authenticate with Google",
            code_gen_sensitive: true,
            default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_file),
            default_value_dynamic: true,
            verify_block: proc do |value|
              UI.user_error!("'#{value}' doesn't seem to be a JSON file") unless FastlaneCore::Helper.json_file?(File.expand_path(value))
              UI.user_error!("Could not find service account json file at path '#{File.expand_path(value)}'") unless File.exist?(File.expand_path(value))
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :json_key_data,
            env_name: "SUPPLY_JSON_KEY_DATA", # TODO
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
    end
  end
end
