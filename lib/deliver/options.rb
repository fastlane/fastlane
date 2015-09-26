require 'fastlane_core'
require 'credentials_manager'

module Deliver
  class Options
    def self.available_options
      @options ||= [
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "DELIVER_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "DELIVER_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
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
                                       raise "Could not find ipa file at path '#{value}'".red unless File.exist?(value)
                                       raise "'#{value}' doesn't seem to be an ipa file".red unless value.end_with?(".ipa")
                                     end),
        FastlaneCore::ConfigItem.new(key: :metadata_folder,
                                     short_option: '-m',
                                     description: "Path to the folder containing the metadata files",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                     short_option: '-w',
                                     description: "Path to the folder containing the screenshots",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_metadata,
                                     description: "Only upload the build - no metadata",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :force,
                                     short_option: "-f",
                                     description: "Skip the HTML file verification",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :submit_for_review,
                                     description: "Submit the new version for Review after uploading everything",
                                     is_string: false,
                                     default_value: false),

        # App Metadata
        # Non Localised
        FastlaneCore::ConfigItem.new(key: :app_icon,
                                     description: "Metadata: The path to the app icon",
                                     optional: true,
                                     short_option: "-l",
                                     verify_block: proc do |value|
                                       raise "Could not find png file at path '#{value}'".red unless File.exist?(value)
                                       raise "'#{value}' doesn't seem to be a png file".red unless value.end_with?(".png")
                                     end),
        FastlaneCore::ConfigItem.new(key: :apple_watch_app_icon,
                                     description: "Metadata: The path to the Apple Watch app icon",
                                     optional: true,
                                     short_option: "-q",
                                     verify_block: proc do |value|
                                       raise "Could not find png file at path '#{value}'".red unless File.exist?(value)
                                       raise "'#{value}' doesn't seem to be a png file".red unless value.end_with?(".png")
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
                                     is_string: false),
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
                                     is_string: false),
      ]
    end
  end
end
