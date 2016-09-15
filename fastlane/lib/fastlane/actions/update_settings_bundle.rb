module Fastlane
  module Actions
    module SharedValues
    end

    module SettingsBundle
      class UpdateParameters
        attr_accessor :root_plist_path
        attr_accessor :version_number
        attr_accessor :build_number
        attr_accessor :version_key

        # options is a Hash with keys corresponding to the
        # attrs of this class
        def initialize(options)
          symbolized_options = options.symbolize_keys

          self.root_plist_path = symbolized_options[:root_plist_path]
          self.version_number = symbolized_options[:version_number]
          self.build_number = symbolized_options[:build_number]
          self.version_key = symbolized_options[:version_key]

          raise "invalid options: #{error_message}" unless valid?
        end

        def valid?
          not (root_plist_path.nil? or
            version_number.nil? or
            build_number.nil? or
            version_key.nil?)
        end

        def error_message
          message = ""
          message << "no root_plist_path. " if root_plist_path.nil?
          message << "no version_number. " if version_number.nil?
          message << "no build_number. " if build_number.nil?
          message << "no version_key. " if version_key.nil?
          message
        end
      end

      class << self
        # options is a Hash
        def update(options)
          update_params = UpdateParameters.new options

          require 'plist'

          # Formatted app version for settings bundle
          current_app_version = "#{update_params.version_number} (#{update_params.build_number})"
      
          # Load Root.plist (raises)
          root_plist = Plist::parse_xml update_params.root_plist_path
      
          # Find the preference specifier for CurrentAppVersion
          preference_specifiers = root_plist["PreferenceSpecifiers"]

          raise "#{update_params.root_plist_path} is not a valid preferences plist" unless preference_specifiers.is_a? Array

          current_app_version_specifier = preference_specifiers.find do |specifier|
            specifier["Key"] == update_params.version_key
          end

          raise "#{update_params.version_key} not found in #{update_params.root_plist_path}" if current_app_version_specifier.nil?
      
          # Update to the new value
          current_app_version_specifier["DefaultValue"] = current_app_version
      
          # Save (raises)
          Plist::Emit.save_plist root_plist, update_params.root_plist_path
        end
      end
    end

=begin
    version_key option is required, e.g.:
    update_settings_bundle version_key: "CurrentAppVersion"
    This key must already exist in the Root.plist
=end
    def update_settings_bundle(options)
      version_key = options.symbolize_keys[:version_key]
      raise "version_key option is required" if version_key.nil?

      # Get the Root.plist path from the project file or allow override.
      root_plist_path = ""

      # Get the current version and build number from the project file,
      # Info.plist, agvtool or elsewhere.
      current_version = "1.0"
      current_build = "1"

      SettingsBundle.update root_plist_path: root_plist_path,
        version_number: current_version,
        build_number: current_build,
        version_key: version_key
    end
  end
end
