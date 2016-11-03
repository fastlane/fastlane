require 'fastlane_core'
require 'credentials_manager'

module Deliver
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "DELIVER_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: user),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "DELIVER_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :app,
                                     short_option: "-p",
                                     env_name: "DELIVER_APP_ID",
                                     description: "The app ID of the app you want to use/modify",
                                     is_string: false), # don't add any verification here, as it's used to store a spaceship ref
        FastlaneCore::ConfigItem.new(key: :ipa,
                                     short_option: "-i",
                                     optional: true,
                                     env_name: "DELIVER_IPA_PATH",
                                     description: "Path to your ipa file",
                                     default_value: Dir["*.ipa"].first,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find ipa file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be an ipa file") unless value.end_with?(".ipa")
                                     end,
                                     conflicting_options: [:pkg],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run.")
                                     end),
        FastlaneCore::ConfigItem.new(key: :pkg,
                                     short_option: "-c",
                                     optional: true,
                                     env_name: "DELIVER_PKG_PATH",
                                     description: "Path to your pkg file",
                                     default_value: Dir["*.pkg"].first,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find pkg file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be a pkg file") unless value.end_with?(".pkg")
                                     end,
                                     conflicting_options: [:ipa],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't use 'pkg' and '#{value.key}' options in one run.")
                                     end),
        FastlaneCore::ConfigItem.new(key: :metadata_path,
                                     short_option: '-m',
                                     description: "Path to the folder containing the metadata files",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                     short_option: '-w',
                                     description: "Path to the folder containing the screenshots",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_binary_upload,
                                     description: "Skip uploading an ipa or pkg to iTunes Connect",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :skip_screenshots,
                                     description: "Don't upload the screenshots",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :app_version,
                                     short_option: '-z',
                                     description: "The version that should be edited or created",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_metadata,
                                     description: "Don't upload the metadata (e.g. title, description), this will still upload screenshots",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :force,
                                     short_option: "-f",
                                     description: "Skip the HTML report file verification",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :submit_for_review,
                                     env_name: "DELIVER_SUBMIT_FOR_REVIEW",
                                     description: "Submit the new version for Review after uploading everything",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :automatic_release,
                                     description: "Should the app be automatically released once it's approved?",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :price_tier,
                                     short_option: "-r",
                                     description: "The price tier of this application",
                                     is_string: false,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :build_number,
                                     short_option: "-n",
                                     description: "If set the given build number (already uploaded to iTC) will be used instead of the current built one",
                                     optional: true,
                                     conflicting_options: [:ipa, :pkg],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't use 'build_number' and '#{value.key}' options in one run.")
                                     end),
        FastlaneCore::ConfigItem.new(key: :app_rating_config_path,
                                     short_option: "-g",
                                     description: "Path to the app rating's config",
                                     is_string: true,
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find config file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be a JSON file") unless value.end_with?(".json")
                                     end),
        FastlaneCore::ConfigItem.new(key: :submission_information,
                                     short_option: "-b",
                                     description: "Extra information for the submission (e.g. third party content)",
                                     is_string: false,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-k",
                                     env_name: "DELIVER_TEAM_ID",
                                     description: "The ID of your iTunes Connect team if you're in multiple teams",
                                     optional: true,
                                     is_string: false, # as we also allow integers, which we convert to strings anyway
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-e",
                                     env_name: "DELIVER_TEAM_NAME",
                                     description: "The name of your iTunes Connect team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :dev_portal_team_id,
                                     short_option: "-s",
                                     env_name: "DELIVER_DEV_PORTAL_TEAM_ID",
                                     description: "The short ID of your Developer Portal team, if you're in multiple teams. Different from your iTC team ID!",
                                     optional: true,
                                     is_string: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :dev_portal_team_name,
                                     short_option: "-y",
                                     env_name: "DELIVER_DEV_PORTAL_TEAM_NAME",
                                     description: "The name of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :itc_provider,
                                     env_name: "DELIVER_ITC_PROVIDER",
                                     description: "The provider short name to be used with the iTMSTransporter to identify your team",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :overwrite_screenshots,
                                     env_name: "DELIVER_OVERWRITE_SCREENSHOTS",
                                     description: "Clear all previously uploaded screenshots before uploading the new ones",
                                     is_string: false,
                                     default_value: false),

        # App Metadata
        # Non Localised
        FastlaneCore::ConfigItem.new(key: :app_icon,
                                     description: "Metadata: The path to the app icon",
                                     optional: true,
                                     short_option: "-l",
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find png file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be a png file") unless value.end_with?(".png")
                                     end),
        FastlaneCore::ConfigItem.new(key: :apple_watch_app_icon,
                                     description: "Metadata: The path to the Apple Watch app icon",
                                     optional: true,
                                     short_option: "-q",
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find png file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be a png file") unless value.end_with?(".png")
                                     end),
        FastlaneCore::ConfigItem.new(key: :copyright,
                                     description: "Metadata: The copyright notice",
                                     optional: true,
                                     is_string: true),
        FastlaneCore::ConfigItem.new(key: :primary_category,
                                     description: "Metadata: The english name of the primary category(e.g. `Business`, `Books`)",
                                     optional: true,
                                     is_string: true),
        FastlaneCore::ConfigItem.new(key: :secondary_category,
                                     description: "Metadata: The english name of the secondary category(e.g. `Business`, `Books`)",
                                     optional: true,
                                     is_string: true),
        FastlaneCore::ConfigItem.new(key: :primary_first_sub_category,
                                     description: "Metadata: The english name of the primary first sub category(e.g. `Educational`, `Puzzle`)",
                                     optional: true,
                                     is_string: true),
        FastlaneCore::ConfigItem.new(key: :primary_second_sub_category,
                                     description: "Metadata: The english name of the primary second sub category(e.g. `Educational`, `Puzzle`)",
                                     optional: true,
                                     is_string: true),
        FastlaneCore::ConfigItem.new(key: :secondary_first_sub_category,
                                     description: "Metadata: The english name of the secondary first sub category(e.g. `Educational`, `Puzzle`)",
                                     optional: true,
                                     is_string: true),
        FastlaneCore::ConfigItem.new(key: :secondary_second_sub_category,
                                     description: "Metadata: The english name of the secondary second sub category(e.g. `Educational`, `Puzzle`)",
                                     optional: true,
                                     is_string: true),
        FastlaneCore::ConfigItem.new(key: :app_review_information,
                                     description: "Metadata: A hash containing the review information",
                                     optional: true,
                                     is_string: false),
        # Localised
        FastlaneCore::ConfigItem.new(key: :description,
                                     description: "Metadata: The localised app description",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :name,
                                     description: "Metadata: The localised app name",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :keywords,
                                     description: "Metadata: An array of localised keywords",
                                     optional: true,
                                     is_string: false,
                                     verify_block: proc do |value|
                                       UI.user_error!(":keywords must be a Hash, with the language being the key") unless value.kind_of?(Hash)
                                       value.each do |language, keywords|
                                         # Auto-convert array to string
                                         keywords = keywords.join(", ") if keywords.kind_of?(Array)
                                         value[language] = keywords

                                         UI.user_error!(":keywords must be a hash with all values being strings") unless keywords.kind_of?(String)
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :release_notes,
                                     description: "Metadata: Localised release notes for this version",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :privacy_url,
                                     description: "Metadata: Localised privacy url",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :support_url,
                                     description: "Metadata: Localised support url",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :marketing_url,
                                     description: "Metadata: Localised marketing url",
                                     optional: true,
                                     is_string: false)
      ]
    end
  end
end
