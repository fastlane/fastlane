require 'fastlane_core'
require 'credentials_manager'

module Supply
  class Options
    def self.available_options
      valid_tracks = %w(production beta alpha rollout)
      @options ||= [
        FastlaneCore::ConfigItem.new(key: :package_name,
                                     env_name: "SUPPLY_PACKAGE_NAME",
                                     short_option: "-p",
                                     description: "The package name of the Application to modify",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:package_name)),
        FastlaneCore::ConfigItem.new(key: :track,
                                     short_option: "-a",
                                     env_name: "SUPPLY_TRACK",
                                     description: "The Track to upload the Application to: #{valid_tracks.join(', ')}",
                                     default_value: 'production',
                                     verify_block: proc do |value|
                                       available = valid_tracks
                                       UI.user_error! "Invalid value '#{value}', must be #{available.join(', ')}" unless available.include? value
                                     end),
        FastlaneCore::ConfigItem.new(key: :rollout,
                                     short_option: "-r",
                                     description: "The percentage of the user fraction when uploading to the rollout track",
                                     default_value: '0.1',
                                     verify_block: proc do |value|
                                       min = 0.05
                                       max = 0.5
                                       UI.user_error! "Invalid value '#{value}', must be between #{min} and #{max}" unless value.to_f.between?(min, max)
                                     end),
        FastlaneCore::ConfigItem.new(key: :metadata_path,
                                     env_name: "SUPPLY_METADATA_PATH",
                                     short_option: "-m",
                                     optional: true,
                                     description: "Path to the directory containing the metadata files",
                                     default_value: (Dir["./fastlane/metadata/android"] + Dir["./metadata"]).first),
        FastlaneCore::ConfigItem.new(key: :key,
                                     env_name: "SUPPLY_KEY",
                                     short_option: "-k",
                                     conflicting_options: [:json_key],
                                     deprecated: 'Use --json_key instead',
                                     description: "The p12 File used to authenticate with Google",
                                     default_value: Dir["*.p12"].first || CredentialsManager::AppfileConfig.try_fetch_value(:keyfile),
                                     verify_block: proc do |value|
                                       UI.user_error! "Could not find p12 file at path '#{File.expand_path(value)}'" unless File.exist?(File.expand_path(value))
                                     end),
        FastlaneCore::ConfigItem.new(key: :issuer,
                                     env_name: "SUPPLY_ISSUER",
                                     short_option: "-i",
                                     conflicting_options: [:json_key],
                                     deprecated: 'Use --json_key instead',
                                     description: "The issuer of the p12 file (email address of the service account)",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:issuer),
                                     verify_block: proc do |value|
                                       UI.important("DEPRECATED --issuer OPTION. Use --json_key instead")
                                     end),
        FastlaneCore::ConfigItem.new(key: :json_key,
                                     env_name: "SUPPLY_JSON_KEY",
                                     short_option: "-j",
                                     conflicting_options: [:issuer, :key],
                                     optional: true, # this is shouldn't be optional but is until --key and --issuer are completely removed
                                     description: "The service account json file used to authenticate with Google",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_file),
                                     verify_block: proc do |value|
                                       UI.user_error! "Could not find service account json file at path '#{File.expand_path(value)}'" unless File.exist?(File.expand_path(value))
                                     end),
        FastlaneCore::ConfigItem.new(key: :apk,
                                     env_name: "SUPPLY_APK",
                                     description: "Path to the APK file to upload",
                                     short_option: "-b",
                                     conflicting_options: [:apk_paths],
                                     default_value: Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-Release.apk")].last,
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error! "Could not find apk file at path '#{value}'" unless File.exist?(value)
                                       UI.user_error! "apk file is not an apk" unless value.end_with?('.apk')
                                     end),
        FastlaneCore::ConfigItem.new(key: :apk_paths,
                                     env_name: "SUPPLY_APK_PATHS",
                                     conflicting_options: [:apk],
                                     optional: true,
                                     type: Array,
                                     description: "An array of paths to APK files to upload",
                                     short_option: "-u",
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not evaluate array from '#{value}'") unless value.kind_of?(Array)
                                       value.each do |path|
                                         UI.user_error! "Could not find apk file at path '#{path}'" unless File.exist?(path)
                                         UI.user_error! "file at path '#{path}' is not an apk" unless path.end_with?('.apk')
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :skip_upload_apk,
                                     env_name: "SUPPLY_SKIP_UPLOAD_APK",
                                     optional: true,
                                     description: "Whether to skip uploading APK",
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
                                     description: "The Track to promote to: #{valid_tracks.join(', ')}",
                                     verify_block: proc do |value|
                                       available = valid_tracks
                                       UI.user_error! "Invalid value '#{value}', must be #{available.join(', ')}" unless available.include? value
                                     end)

      ]
    end
  end
end
