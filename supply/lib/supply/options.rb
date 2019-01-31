require 'fastlane_core/configuration/config_item'
require 'credentials_manager/appfile_config'

module Supply
  class Options
    # rubocop:disable Metrics/PerceivedComplexity
    def self.available_options
      default_tracks = %w(production beta alpha internal rollout)
      @options ||= [
        FastlaneCore::ConfigItem.new(key: :package_name,
                                     env_name: "SUPPLY_PACKAGE_NAME",
                                     short_option: "-p",
                                     description: "The package name of the application to use",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:package_name),
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :track,
                                     short_option: "-a",
                                     env_name: "SUPPLY_TRACK",
                                     description: "The track of the application to use. The default available tracks are: #{default_tracks.join(', ')}",
                                     default_value: 'production'),
        FastlaneCore::ConfigItem.new(key: :rollout,
                                     short_option: "-r",
                                     description: "The percentage of the user fraction when uploading to the rollout track",
                                     optional: true,
                                     verify_block: proc do |value|
                                       min = 0.0
                                       max = 1.0
                                       UI.user_error!("Invalid value '#{value}', must be greater than #{min} and less than #{max}") unless value.to_f > min && value.to_f <= max
                                     end),
        FastlaneCore::ConfigItem.new(key: :metadata_path,
                                     env_name: "SUPPLY_METADATA_PATH",
                                     short_option: "-m",
                                     optional: true,
                                     description: "Path to the directory containing the metadata files",
                                     default_value: (Dir["./fastlane/metadata/android"] + Dir["./metadata"]).first,
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :key,
                                     env_name: "SUPPLY_KEY",
                                     short_option: "-k",
                                     conflicting_options: [:json_key],
                                     deprecated: 'Use `--json_key` instead',
                                     description: "The p12 File used to authenticate with Google",
                                     code_gen_sensitive: true,
                                     default_value: Dir["*.p12"].first || CredentialsManager::AppfileConfig.try_fetch_value(:keyfile),
                                     default_value_dynamic: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find p12 file at path '#{File.expand_path(value)}'") unless File.exist?(File.expand_path(value))
                                     end),
        FastlaneCore::ConfigItem.new(key: :issuer,
                                     env_name: "SUPPLY_ISSUER",
                                     short_option: "-i",
                                     conflicting_options: [:json_key],
                                     deprecated: 'Use `--json_key` instead',
                                     description: "The issuer of the p12 file (email address of the service account)",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:issuer),
                                     default_value_dynamic: true,
                                     verify_block: proc do |value|
                                       UI.important("DEPRECATED --issuer OPTION. Use --json_key instead")
                                     end),
        FastlaneCore::ConfigItem.new(key: :json_key,
                                     env_name: "SUPPLY_JSON_KEY",
                                     short_option: "-j",
                                     conflicting_options: [:issuer, :key, :json_key_data],
                                     optional: true, # this shouldn't be optional but is until --key and --issuer are completely removed
                                     description: "The path to a file containing service account JSON, used to authenticate with Google",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_file),
                                     default_value_dynamic: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find service account json file at path '#{File.expand_path(value)}'") unless File.exist?(File.expand_path(value))
                                       UI.user_error!("'#{value}' doesn't seem to be a JSON file") unless FastlaneCore::Helper.json_file?(File.expand_path(value))
                                     end),
        FastlaneCore::ConfigItem.new(key: :json_key_data,
                                     env_name: "SUPPLY_JSON_KEY_DATA",
                                     short_option: "-c",
                                     conflicting_options: [:issuer, :key, :json_key],
                                     optional: true,
                                     description: "The raw service account JSON data used to authenticate with Google",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_data_raw),
                                     default_value_dynamic: true,
                                     verify_block: proc do |value|
                                       begin
                                         JSON.parse(value)
                                       rescue JSON::ParserError
                                         UI.user_error!("Could not parse service account json  JSON::ParseError")
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :apk,
                                     env_name: "SUPPLY_APK",
                                     description: "Path to the APK file to upload",
                                     short_option: "-b",
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
                                     conflicting_options: [:apk, :aab, :aab_paths],
                                     optional: true,
                                     type: Array,
                                     description: "An array of paths to APK files to upload",
                                     short_option: "-u",
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not evaluate array from '#{value}'") unless value.kind_of?(Array)
                                       value.each do |path|
                                         UI.user_error!("Could not find apk file at path '#{path}'") unless File.exist?(path)
                                         UI.user_error!("file at path '#{path}' is not an apk") unless path.end_with?('.apk')
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :aab,
                                     env_name: "SUPPLY_AAB",
                                     description: "Path to the AAB file to upload",
                                     short_option: "-f",
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
                                     conflicting_options: [:apk, :apk_paths, :aab],
                                     optional: true,
                                     type: Array,
                                     description: "An array of paths to AAB files to upload",
                                     short_option: "-z",
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not evaluate array from '#{value}'") unless value.kind_of?(Array)
                                       value.each do |path|
                                         UI.user_error!("Could not find aab file at path '#{path}'") unless File.exist?(path)
                                         UI.user_error!("file at path '#{path}' is not an aab") unless path.end_with?('.aab')
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :skip_upload_apk,
                                     env_name: "SUPPLY_SKIP_UPLOAD_APK",
                                     optional: true,
                                     description: "Whether to skip uploading APK",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_upload_aab,
                                     env_name: "SUPPLY_SKIP_UPLOAD_AAB",
                                     optional: true,
                                     description: "Whether to skip uploading AAB",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_upload_metadata,
                                     env_name: "SUPPLY_SKIP_UPLOAD_METADATA",
                                     optional: true,
                                     description: "Whether to skip uploading metadata",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_upload_images,
                                     env_name: "SUPPLY_SKIP_UPLOAD_IMAGES",
                                     optional: true,
                                     description: "Whether to skip uploading images, screenshots not included",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_upload_screenshots,
                                     env_name: "SUPPLY_SKIP_UPLOAD_SCREENSHOTS",
                                     optional: true,
                                     description: "Whether to skip uploading SCREENSHOTS",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :track_promote_to,
                                     env_name: "SUPPLY_TRACK_PROMOTE_TO",
                                     optional: true,
                                     description: "The track to promote to. The default available tracks are: #{default_tracks.join(', ')}"),
        FastlaneCore::ConfigItem.new(key: :validate_only,
                                     env_name: "SUPPLY_VALIDATE_ONLY",
                                     optional: true,
                                     description: "Only validate changes with Google Play rather than actually publish",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :mapping,
                                     env_name: "SUPPLY_MAPPING",
                                     description: "Path to the mapping file to upload",
                                     short_option: "-d",
                                     conflicting_options: [:mapping_paths],
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find mapping file at path '#{value}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :mapping_paths,
                                     env_name: "SUPPLY_MAPPING_PATHS",
                                     conflicting_options: [:mapping],
                                     optional: true,
                                     type: Array,
                                     description: "An array of paths to mapping files to upload",
                                     short_option: "-s",
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not evaluate array from '#{value}'") unless value.kind_of?(Array)
                                       value.each do |path|
                                         UI.user_error!("Could not find mapping file at path '#{path}'") unless File.exist?(path)
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :root_url,
                                     env_name: "SUPPLY_ROOT_URL",
                                     description: "Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not parse URL '#{value}'") unless value =~ URI.regexp
                                     end),
        FastlaneCore::ConfigItem.new(key: :check_superseded_tracks,
                                     env_name: "SUPPLY_CHECK_SUPERSEDED_TRACKS",
                                     optional: true,
                                     description: "Check the other tracks for superseded versions and disable them",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :timeout,
                                     env_name: "SUPPLY_TIMEOUT",
                                     optional: true,
                                     description: "Timeout for read, open, and send (in seconds)",
                                     type: Integer,
                                     default_value: 300),
        FastlaneCore::ConfigItem.new(key: :deactivate_on_promote,
                                     env_name: "SUPPLY_DEACTIVATE_ON_PROMOTE",
                                     optional: true,
                                     description: "When promoting to a new track, deactivate the binary in the origin track",
                                     is_string: false,
                                     default_value: true),
        FastlaneCore::ConfigItem.new(key: :version_codes_to_retain,
                                     optional: true,
                                     type: Array,
                                     description: "An array of version codes to retain when publishing a new APK",
                                     verify_block: proc do |version_codes|
                                       UI.user_error!("Could not evaluate array from '#{version_codes}'") unless version_codes.kind_of?(Array)
                                       version_codes.each do |version_code|
                                         UI.user_error!("Version code '#{version_code}' is not an integer") unless version_code.kind_of?(Integer)
                                       end
                                     end)
      ]
    end
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
