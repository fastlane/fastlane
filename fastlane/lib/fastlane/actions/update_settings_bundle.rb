module Fastlane
  module Actions
    module SharedValues
      SETTINGS_PLIST_PATH = :SETTINGS_PLIST_PATH
    end

    # SettingsBundle utility module
    module SettingsBundle
      class UpdateParameters
        attr_accessor :settings_plist_path
        attr_accessor :version_key

        # options is a Hash with keys corresponding to the
        # attrs of this class
        def initialize(options)
          symbolized_options = options.symbolize_keys

          self.settings_plist_path = symbolized_options[:settings_plist_path]
          self.version_key = symbolized_options[:version_key]

          raise "invalid options: #{error_message}" unless valid?
        end

        def valid?
          not (settings_plist_path.nil? or
            version_key.nil?)
        end

        def error_message
          message = ""
          message << "no settings_plist_path. " if settings_plist_path.nil?
          message << "no version_key. " if version_key.nil?
          message
        end
      end

      class << self
        # options is a Hash
        def update(options)
          update_params = UpdateParameters.new options

          require 'plist'
      
          # Load Root.plist (raises)
          root_plist = Plist::parse_xml update_params.settings_plist_path
      
          # Find the preference specifier for CurrentAppVersion
          preference_specifiers = root_plist["PreferenceSpecifiers"]

          raise "#{update_params.settings_plist_path} is not a valid preferences plist" unless preference_specifiers.is_a? Array

          current_app_version_specifier = preference_specifiers.find do |specifier|
            specifier["Key"] == update_params.version_key
          end

          raise "#{update_params.version_key} not found in #{update_params.settings_plist_path}" if current_app_version_specifier.nil?

          Actions.lane_context[SharedValues::SETTINGS_PLIST_PATH] = settings_plist_path

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
    class UpdateSettingsBundle < Action
      class << self
        def description
          <<-EOF
          Update the current version and build number in the settings bundle.
          EOF
        end

        def details
          <<-EOF
          After updating the marketing version and/or build number,
          update a key in the settings bundle to reflect this information.
          EOF
        end

        def available_options
          # TODO
          [
          ]
        end

        def author
          <<-EOF
            Jimmy Dee (https://github.com/jdee)
          EOF
        end

        def is_supported?(platform)
          # TODO: Review Mac
          platform == :ios
        end

        def output
          [
            [
              'SETTINGS_PLIST_PATH',
              'The plist path specified or taken from the project file'
            ]
          ]
        end

        def run(params)
        end
      end
    end
  end
end
