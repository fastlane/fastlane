require 'fastlane_core'
require 'credentials_manager'

module Chiizu
  class Options
    def self.available_options
      output_directory = (File.directory?("fastlane") ? "fastlane/screenshots" : "screenshots")

      @@options ||= [
        FastlaneCore::ConfigItem.new(key: :locales,
                                     description: "A list of locales which should be used",
                                     short_option: "-q",
                                     type: Array,
                                     default_value: ['en-US','fr-FR','ja-JP']),
        FastlaneCore::ConfigItem.new(key: :clear_previous_screenshots,
                                     env_name: 'CHIIZU_CLEAR_PREVIOUS_SCREENSHOTS',
                                     description: "Enabling this option will automatically clear previously generated screenshots before running chiizu",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :output_directory,
                                     short_option: "-o",
                                     env_name: "CHIIZU_OUTPUT_DIRECTORY",
                                     description: "The directory where to store the screenshots",
                                     default_value: output_directory),
        FastlaneCore::ConfigItem.new(key: :skip_open_summary,
                                     env_name: 'CHIIZU_SKIP_OPEN_SUMMARY',
                                     description: "Don't open the HTML summary after running `chiizu`",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :app_package_name,
                                     env_name: 'CHIIZU_APP_PACKAGE_NAME',
                                     short_option: "-a",
                                     optional: true,
                                     description: "The package name of the app under test (e.g. com.yourcompany.yourapp)",
                                     default_value: ENV["CHIIZU_APP_PACKAGE_NAME"] || CredentialsManager::AppfileConfig.try_fetch_value(:package_name)),
        FastlaneCore::ConfigItem.new(key: :tests_package_name,
                                     env_name: 'CHIIZU_TESTS_PACKAGE_NAME',
                                     optional: true,
                                     description: "The package name of the tests bundle (e.g. com.yourcompany.yourapp.test)"),
        # TODO need better default value calculation here

        FastlaneCore::ConfigItem.new(key: :app_apk_path,
                                     env_name: 'CHIIZU_APP_APK_PATH',
                                     optional: true,
                                     description: "The path to the APK for the app under test",
                                     short_option: "-k",
                                     default_value:  Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-debug.apk")].last,
                                     verify_block: proc do |value|
                                       raise "Could not find APK file at path '#{value}'".red unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :tests_apk_path,
                                     env_name: 'CHIIZU_TESTS_APK_PATH',
                                     optional: true,
                                     description: "The path to the APK for the the tests bundle",
                                     short_option: "-b",
                                     default_value:  Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-debug-androidTest-unaligned.apk")].last,
                                     verify_block: proc do |value|
                                       raise "Could not find APK file at path '#{value}'".red unless File.exist?(value)
                                     end),

        # Everything around building
        FastlaneCore::ConfigItem.new(key: :clean,
                                     short_option: "-c",
                                     env_name: "CHIIZU_CLEAN",
                                     description: "Should the project be cleaned before building it?",
                                     is_string: false,
                                     default_value: false)
      ]
    end
  end
end
