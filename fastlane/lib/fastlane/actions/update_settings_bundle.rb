module Fastlane
  module Actions
    module SharedValues
      SETTINGS_PLIST_PATH = :SETTINGS_PLIST_PATH
    end

    # SettingsBundle utility module
    module SettingsBundle
      class << self
        # options is a Hash
        def update(options)
          require 'plist'

          # Load Root.plist (raises)
          root_plist = Plist.parse_xml options[:path]

          # Find the preference specifier for the setting key
          preference_specifiers = root_plist["PreferenceSpecifiers"]

          raise "#{update_params.settings_plist_path} is not a valid preferences plist" unless preference_specifiers.kind_of? Array

          setting_key = options[:setting_key]
          current_app_version_specifier = preference_specifiers.find do |specifier|
            specifier["Key"] == setting_key
          end

          raise "#{update_params.version_key} not found in #{update_params.settings_plist_path}" if current_app_version_specifier.nil?

          # Formatted app version for settings bundle:
          # version (build)
          formatted_version = "#{Actions.lane_context[SharedValues::VERSION_NUMBER]} (#{Actions.lane_context[SharedValues::BUILD_NUMBER]})"

          # Update to the new value
          current_app_version_specifier["DefaultValue"] = formatted_version

          # Save (raises)
          Plist::Emit.save_plist root_plist, update_params.settings_plist_path
        end
      end
    end

    # UpdateSettingsBundle action
    class UpdateSettingsBundleAction < Action
      class << self
        def description
          <<-EOF
          Update the current version and build number in the settings bundle
          EOF
        end

        def details
          <<-EOF
          After updating the marketing version and/or build number,
          update a key in the settings bundle to reflect this information.
          EOF
        end

        def available_options
          [
            FastlaneCore::ConfigItem.new(key: :path,
                                         env_name: "FL_SETTING_BUNDLE_PATH",
                                         description: "(required) you must specify the path to the plist file in the settings bundle, e.g. Resources/Settings.Bundle/Root.plist",
                                         optional: false,
                                         verify_block: proc do |value|
                                           UI.user_error!("The supplied path is not to a plist file") unless value.end_with? ".plist"
                                           UI.user_error!("Could not find plist file") if !File.exist?(value) and !Helper.is_test?
                                         end),
            # Not sure if there's any limitation on the setting key to validate
            FastlaneCore::ConfigItem.new(key: :setting_key,
                                         env_name: "FL_SETTING_BUNDLE_SETTING_KEY",
                                         description: "(required) the key identifier to update in the Root.plist or other plist file",
                                         optional: false)
          ]
        end

        def author
          <<-EOF
            Jimmy Dee (https://github.com/jdee)
          EOF
        end

        def is_supported?(platform)
          platform == :ios
        end

        def output
          [
            [
              'SETTINGS_PLIST_PATH',
              'The path to the updated plist file'
            ]
          ]
        end

        def category
          :project
        end

        def run(params)
          # raises if can't parse the file
          SettingsBundle.update params
          Actions.lane_context[SharedValues::SETTINGS_PLIST_PATH] = params[:path]
        end
      end
    end
  end
end
