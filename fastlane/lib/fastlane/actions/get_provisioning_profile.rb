module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
      SIGH_PROFILE_PATHS = :SIGH_PROFILE_PATHS
      SIGH_UDID = :SIGH_UDID # deprecated
      SIGH_UUID = :SIGH_UUID
      SIGH_NAME = :SIGH_NAME
      SIGH_PROFILE_TYPE ||= :SIGH_PROFILE_TYPE
    end

    class GetProvisioningProfileAction < Action
      def self.run(values)
        require 'sigh'
        require 'credentials_manager/appfile_config'

        # Only set :api_key from SharedValues if :api_key_path isn't set (conflicting options)
        unless values[:api_key_path]
          values[:api_key] ||= Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY]
        end

        Sigh.config = values # we already have the finished config

        path = Sigh::Manager.start

        Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = path # absolute path
        Actions.lane_context[SharedValues::SIGH_PROFILE_PATHS] ||= []
        Actions.lane_context[SharedValues::SIGH_PROFILE_PATHS] << path

        uuid = ENV["SIGH_UUID"] || ENV["SIGH_UDID"] # the UUID of the profile
        name = ENV["SIGH_NAME"] # the name of the profile
        Actions.lane_context[SharedValues::SIGH_UUID] = Actions.lane_context[SharedValues::SIGH_UDID] = uuid if uuid
        Actions.lane_context[SharedValues::SIGH_NAME] = Actions.lane_context[SharedValues::SIGH_NAME] = name if name

        set_profile_type(values, ENV["SIGH_PROFILE_ENTERPRISE"])

        return uuid # returns uuid of profile
      end

      def self.set_profile_type(values, enterprise)
        profile_type = "app-store"
        profile_type = "ad-hoc" if values[:adhoc]
        profile_type = "development" if values[:development]
        profile_type = "developer-id" if values[:developer_id]
        profile_type = "enterprise" if enterprise

        UI.message("Setting Provisioning Profile type to '#{profile_type}'")

        Actions.lane_context[SharedValues::SIGH_PROFILE_TYPE] = profile_type
      end

      def self.description
        "Generates a provisioning profile, saving it in the current folder (via _sigh_)"
      end

      def self.author
        "KrauseFx"
      end

      # rubocop:disable Lint/MissingKeysOnSharedArea
      def self.output
        [
          ['SIGH_PROFILE_PATH', 'A path in which certificates, key and profile are exported'],
          ['SIGH_PROFILE_PATHS', 'Paths in which certificates, key and profile are exported'],
          ['SIGH_UUID', 'UUID (Universally Unique IDentifier) of a provisioning profile'],
          ['SIGH_NAME', 'The name of the profile'],
          ['SIGH_PROFILE_TYPE', 'The profile type, can be app-store, ad-hoc, development, enterprise, developer-id, can be used in `build_app` as a default value for `export_method`']
        ]
      end

      def self.return_value
        "The UUID of the profile sigh just fetched/generated"
      end

      def self.return_type
        :string
      end

      def self.details
        "**Note**: It is recommended to use [match](https://docs.fastlane.tools/actions/match/) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your provisioning profiles. Use _sigh_ directly only if you want full control over what's going on and know more about codesigning."
      end

      def self.available_options
        require 'sigh'
        Sigh::Options.available_options
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'get_provisioning_profile',
          'sigh # alias for "get_provisioning_profile"',
          'get_provisioning_profile(
            adhoc: true,
            force: true,
            filename: "myFile.mobileprovision"
          )'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
