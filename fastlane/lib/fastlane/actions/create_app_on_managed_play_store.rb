module Fastlane
  module Actions
    class CreateAppOnManagedPlayStoreAction < Action
      def self.run(params)
        unless params[:json_key] || params[:json_key_data]
          UI.important("To not be asked about this value, you can specify it using 'json_key'")
          params[:json_key] = UI.input("The service account json file used to authenticate with Google: ")
        end

        FastlaneCore::PrintTable.print_values(
          config: params,
          mask_keys: [:json_key_data],
          title: "Summary for create_app_on_managed_play_store"
        )

        require "google/apis/playcustomapp_v1"

        # Auth Info
        @keyfile = params[:json_key]
        @developer_account = params[:developer_account_id]

        # App Info
        @apk_path = params[:apk]
        @app_title = params[:app_title]
        @language_code = params[:language]

        # login
        scope = 'https://www.googleapis.com/auth/androidpublisher'
        credentials = JSON.parse(File.open(@keyfile, 'rb').read)
        auth_client = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://oauth2.googleapis.com/token',
          audience: 'https://oauth2.googleapis.com/token',
          scope: scope,
          issuer: credentials['client_id'],
          signing_key: OpenSSL::PKey::RSA.new(credentials['private_key'], nil)
        )
        UI.message('auth_client: ' + auth_client.inspect)
        auth_client.fetch_access_token!

        # service
        play_custom_apps = Google::Apis::PlaycustomappV1::PlaycustomappService.new
        play_custom_apps.authorization = auth_client
        UI.message('play_custom_apps with auth: ' + play_custom_apps.inspect)

        # app
        custom_app = Google::Apis::PlaycustomappV1::CustomApp.new(title: @app_title, language_code: @language_code)
        UI.message('custom_app: ' + custom_app.inspect)

        # create app
        returned = play_custom_apps.create_account_custom_app(
          @developer_account,
          custom_app,
          upload_source: @apk_path
        ) do |created_app, error|
          if error.nil?
            puts("Success: #{created_app}.")
            UI.success(created_app)
            UI.success(created_app.inspect)
          else
            puts("Error: #{error}")
            UI.error(error.inspect)
          end
        end
        UI.message('returned: ' + returned.inspect)
      end

      def self.description
        "Create Managed Google Play Apps"
      end

      def self.authors
        ["janpio"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Create new apps on Managed Google Play."
      end

      def self.example_code
        [
          "create_app_on_managed_play_store(
            json_key: 'path/to/you/json/key/file',
            developer_account_id: 'developer_account_id', # obtained using the get_managed_play_store_publishing_rights action (or looking at the Play Console url)
            app_title: 'Your app title',
            language: 'en_US', # primary app language in BCP 47 format
            apk: '/files/app-release.apk'
          )"
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :json_key,
            env_name: "SUPPLY_JSON_KEY",
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
          ),
          # developer_account
          FastlaneCore::ConfigItem.new(key: :developer_account_id,
            short_option: "-k",
            env_name: "PRODUCE_ITC_TEAM_ID",
            description: "The ID of your Google Play Console account. Can be obtained from the URL when you log in (`https://play.google.com/apps/publish/?account=...` or when you 'Obtain private app publishing rights' (https://developers.google.com/android/work/play/custom-app-api/get-started#retrieve_the_developer_account_id)",
            optional: false,
            is_string: false, # as we also allow integers, which we convert to strings anyway
            code_gen_sensitive: true,
            default_value: CredentialsManager::AppfileConfig.try_fetch_value(:developer_account_id),
            default_value_dynamic: true,
            verify_block: proc do |value|
              raise UI.error("No Developer Account ID given, pass using `developer_account_id: 123456789`") if value.to_s.empty?
            end),
          FastlaneCore::ConfigItem.new(
            key: :apk,
            env_name: "SUPPLY_APK",
            description: "Path to the APK file to upload",
            short_option: "-b",
            conflicting_options: [:apk_paths, :aab],
            code_gen_sensitive: true,
            default_value: Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-Release.apk")].last,
            default_value_dynamic: true,
            optional: true,
            verify_block: proc do |value|
              UI.user_error!("Could not find apk file at path '#{value}'") unless File.exist?(value)
              UI.user_error!("apk file is not an apk") unless value.end_with?('.apk')
            end
          ),
          # title
          FastlaneCore::ConfigItem.new(key: :app_title,
            env_name: "PRODUCE_APP_NAME",
            short_option: "-q",
            description: "App Title",
            optional: false,
            verify_block: proc do |value|
              raise UI.error("No App Title given, pass using `app_title: 'Title'`") if value.to_s.empty?
            end),
          # language
          FastlaneCore::ConfigItem.new(key: :language,
            short_option: "-m",
            env_name: "PRODUCE_LANGUAGE",
            description: "Default app language (e.g. 'en_US')",
            default_value: "en_US",
            optional: false,
            verify_block: proc do |language|
              unless AvailablePlayStoreLanguages.all_languages.include?(language)
                UI.user_error!("Please enter one of available languages: #{AvailablePlayStoreLanguages.all_languages}")
              end
            end)
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

# https://support.google.com/googleplay/android-developer/answer/3125566?hl=en
# => Add your own text translations & localized graphic assets => See available languages => replace `-` with `_`
# %w => https://stackoverflow.com/a/1274703/252627
class AvailablePlayStoreLanguages
  def self.all_languages
    %w[
      af
      am
      ar
      az_AZ
      be
      bg
      bn_BD
      ca
      cs_CZ
      da_DK
      de_DE
      el_GR
      en_AU
      en_CA
      en_GB
      en_IN
      en_SG
      en_US
      en_ZA
      es_419
      es_ES
      es_US
      et
      eu_ES
      fa
      fi_FI
      fil
      fr_CA
      fr_FR
      gl_ES
      hi_IN
      hr
      hu_HU
      hy_AM
      id
      is_IS
      it_IT
      iw_IL
      ja_JP
      ka_GE
      km_KH
      kn_IN
      ko_KR
      ky_KG
      lo_LA
      lt
      lv
      mk_MK
      ml_IN
      mn_MN
      mr_IN
      ms
      ms_MY
      my_MM
      ne_NP
      nl_NL
      no_NO
      pl_PL
      pt_BR
      pt_PT
      rm
      ro
      ru_RU
      si_LK
      sk
      sl
      sr
      sv_SE
      sw
      ta_IN
      te_IN
      th
      tr_TR
      uk
      vi
      zh_CN
      zh_HK
      zh_TW
      zu
    ]
  end
end
