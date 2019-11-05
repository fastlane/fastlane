require 'fastlane_core/core_ext/cfpropertylist'

module Fastlane
  module Actions
    class ClearDerivedDataAction < Action
      def self.run(options)
        path = File.expand_path(options[:derived_data_path])
        UI.message("Derived Data path located at: #{path}")
        FileUtils.rm_rf(path) if File.directory?(path)
        UI.success("Successfully cleared Derived Data ♻️")
      end

      # Helper Methods
      def self.xcode_preferences
        file = File.expand_path("~/Library/Preferences/com.apple.dt.Xcode.plist")
        if File.exist?(file)
          plist = CFPropertyList::List.new(file: file).value
          return CFPropertyList.native_types(plist) unless plist.nil?
        end
        return nil
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Deletes the Xcode Derived Data"
      end

      def self.details
        "Deletes the Derived Data from path set on Xcode or a supplied path"
      end

      def self.available_options
        path = xcode_preferences ? xcode_preferences['IDECustomDerivedDataLocation'] : nil
        path ||= "~/Library/Developer/Xcode/DerivedData"
        [
          FastlaneCore::ConfigItem.new(key: :derived_data_path,
                                       env_name: "DERIVED_DATA_PATH",
                                       description: "Custom path for derivedData",
                                       default_value_dynamic: true,
                                       default_value: path)
        ]
      end

      def self.output
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'clear_derived_data',
          'clear_derived_data(derived_data_path: "/custom/")'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
