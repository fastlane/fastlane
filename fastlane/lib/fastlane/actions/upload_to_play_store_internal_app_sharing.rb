module Fastlane
  module Actions
    class UploadToPlayStoreInternalAppSharingAction < Action
      def self.run(params)
        require 'supply'

        # If no APK params were provided, try to fill in the values from lane context, preferring
        # the multiple APKs over the single APK if set.
        if params[:apk_paths].nil? && params[:apk].nil?
          all_apk_paths = Actions.lane_context[SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS] || []
          if all_apk_paths.size > 1
            params[:apk_paths] = all_apk_paths
          else
            params[:apk] = Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]
          end
        end

        # If no AAB param was provided, try to fill in the value from lane context.
        # First GRADLE_ALL_AAB_OUTPUT_PATHS if only one
        # Else from GRADLE_AAB_OUTPUT_PATH
        if params[:aab].nil?
          all_aab_paths = Actions.lane_context[SharedValues::GRADLE_ALL_AAB_OUTPUT_PATHS] || []
          if all_aab_paths.count == 1
            params[:aab] = all_aab_paths.first
          else
            params[:aab] = Actions.lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH]
          end
        end

        Supply.config = params # we already have the finished config

        Supply::Uploader.new.perform_upload_to_internal_app_sharing
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload binaries to Google Play Internal App Sharing (via _supply_)"
      end

      def self.details
        "More information: https://docs.fastlane.tools/actions/upload_to_play_store_internal_app_sharing/"
      end

      def self.available_options
        @options ||= [
          FastlaneCore::ConfigItem.new(key: :package_name,
                                       env_name: "SUPPLY_PACKAGE_NAME",
                                       short_option: "-p",
                                       description: "The package name of the application to use",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:package_name),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :json_key,
                                       env_name: "SUPPLY_JSON_KEY",
                                       short_option: "-j",
                                       conflicting_options: [:json_key_data],
                                       description: "The path to a file containing service account JSON, used to authenticate with Google",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_file),
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find service account json file at path '#{File.expand_path(value)}'") unless File.exist?(File.expand_path(value))
                                         UI.user_error!("'#{value}' doesn't seem to be a JSON file") unless FastlaneCore::Helper.json_file?(File.expand_path(value))
                                       end),
          FastlaneCore::ConfigItem.new(key: :json_key_data,
                                       env_name: "SUPPLY_JSON_KEY_DATA",
                                       short_option: "-c",
                                       description: "The raw service account JSON data used to authenticate with Google",
                                       conflicting_options: [:json_key],
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_data_raw),
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         begin
                                           JSON.parse(value)
                                         rescue JSON::ParserError
                                           UI.user_error!("Could not parse service account json: JSON::ParseError")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: "SUPPLY_APK",
                                       short_option: "-b",
                                       description: "Path to the APK file to upload",
                                       conflicting_options: [:apk_paths, :aab, :aab_paths],
                                       code_gen_sensitive: true,
                                       default_value: Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-Release.apk")].last,
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find apk file at path '#{value}'") unless File.exist?(value)
                                         UI.user_error!("apk file is not an apk") unless value.end_with?('.apk')
                                       end),
          FastlaneCore::ConfigItem.new(key: :apk_paths,
                                       env_name: "SUPPLY_APK_PATHS",
                                       short_option: "-u",
                                       description: "An array of paths to APK files to upload",
                                       conflicting_options: [:apk, :aab, :aab_paths],
                                       code_gen_sensitive: true,
                                       type: Array,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not evaluate array from '#{value}'") unless value.kind_of?(Array)
                                         value.each do |path|
                                           UI.user_error!("Could not find apk file at path '#{path}'") unless File.exist?(path)
                                           UI.user_error!("file at path '#{path}' is not an apk") unless path.end_with?('.apk')
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :aab,
                                       env_name: "SUPPLY_AAB",
                                       short_option: "-f",
                                       description: "Path to the AAB file to upload",
                                       conflicting_options: [:apk, :apk_paths, :aab_paths],
                                       code_gen_sensitive: true,
                                       default_value: Dir["*.aab"].last || Dir[File.join("app", "build", "outputs", "bundle", "release", "bundle.aab")].last,
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find aab file at path '#{value}'") unless File.exist?(value)
                                         UI.user_error!("aab file is not an aab") unless value.end_with?('.aab')
                                       end),
          FastlaneCore::ConfigItem.new(key: :aab_paths,
                                       env_name: "SUPPLY_AAB_PATHS",
                                       short_option: "-z",
                                       description: "An array of paths to AAB files to upload",
                                       conflicting_options: [:apk, :apk_paths, :aab],
                                       code_gen_sensitive: true,
                                       type: Array,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not evaluate array from '#{value}'") unless value.kind_of?(Array)
                                         value.each do |path|
                                           UI.user_error!("Could not find aab file at path '#{path}'") unless File.exist?(path)
                                           UI.user_error!("file at path '#{path}' is not an aab") unless path.end_with?('.aab')
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                       env_name: "SUPPLY_TIMEOUT",
                                       optional: true,
                                       description: "Timeout for read, open, and send (in seconds)",
                                       type: Integer,
                                       default_value: 300), # 5 minutes
          FastlaneCore::ConfigItem.new(key: :root_url,
                                       env_name: "SUPPLY_ROOT_URL",
                                       description: "Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not parse URL '#{value}'") unless value =~ URI.regexp
                                       end)
        ]
      end

      def self.output
      end

      def self.return_value
        "Returns a string containing the download URL for the uploaded APK/AAB (or array of strings if multiple were uploaded)."
      end

      def self.authors
        ["andrewhavens"]
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.example_code
        ["upload_to_play_store_internal_app_sharing"]
      end

      def self.category
        :production
      end
    end
  end
end
