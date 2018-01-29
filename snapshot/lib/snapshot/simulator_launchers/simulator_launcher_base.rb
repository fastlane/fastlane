require 'plist'

require_relative '../module'
require_relative '../test_command_generator'
require_relative '../collector'
require_relative '../fixes/hardware_keyboard_fix'
require_relative '../fixes/simulator_zoom_fix'

module Snapshot
  class SimulatorLauncherBase
    attr_accessor :collected_errors

    # The number of times we failed on launching the simulator... sigh
    attr_accessor :current_number_of_retries_due_to_failing_simulator
    attr_accessor :launcher_config

    def initialize(launcher_configuration: nil)
      @launcher_config = launcher_configuration
    end

    def collected_errors
      @collected_errors ||= []
    end

    def current_number_of_retries_due_to_failing_simulator
      @current_number_of_retries_due_to_failing_simulator || 0
    end

    def prepare_for_launch(device_types, language, locale, launch_arguments)
      screenshots_path = TestCommandGenerator.derived_data_path
      FileUtils.rm_rf(File.join(screenshots_path, "Logs"))
      FileUtils.rm_rf(screenshots_path) if launcher_config.clean
      FileUtils.mkdir_p(screenshots_path)

      FileUtils.mkdir_p(CACHE_DIR)
      FileUtils.mkdir_p(SCREENSHOTS_DIR)

      File.write(File.join(CACHE_DIR, "language.txt"), language)
      File.write(File.join(CACHE_DIR, "locale.txt"), locale || "")
      File.write(File.join(CACHE_DIR, "snapshot-launch_arguments.txt"), launch_arguments.last)

      prepare_simulators_for_launch(device_types, language: language, locale: locale)
    end

    def prepare_simulators_for_launch(device_types, language: nil, locale: nil)
      # Kill and shutdown all currently running simulators so that the following settings
      # changes will be picked up when they are started again.
      Snapshot.kill_simulator # because of https://github.com/fastlane/fastlane/issues/2533
      `xcrun simctl shutdown booted &> /dev/null`

      Fixes::SimulatorZoomFix.patch
      Fixes::HardwareKeyboardFix.patch

      device_types.each do |type|
        if launcher_config.erase_simulator || launcher_config.localize_simulator
          erase_simulator(type)
          if launcher_config.localize_simulator
            localize_simulator(type, language, locale)
          end
        elsif launcher_config.reinstall_app
          # no need to reinstall if device has been erased
          uninstall_app(type)
        end
      end
    end

    # pass an array of device types
    def add_media(device_types, media_type, paths)
      media_type = media_type.to_s

      device_types.each do |device_type|
        UI.verbose("Adding #{media_type}s to #{device_type}...")
        device_udid = TestCommandGenerator.device_udid(device_type)

        UI.message("Launch Simulator #{device_type}")
        Helper.backticks("xcrun instruments -w #{device_udid} &> /dev/null")

        paths.each do |path|
          UI.message("Adding '#{path}'")
          Helper.backticks("xcrun simctl add#{media_type} #{device_udid} #{path.shellescape} &> /dev/null")
        end
      end
    end

    def uninstall_app(device_type)
      UI.verbose("Uninstalling app '#{launcher_config.app_identifier}' from #{device_type}...")
      launcher_config.app_identifier ||= UI.input("App Identifier: ")
      device_udid = TestCommandGenerator.device_udid(device_type)

      UI.message("Launch Simulator #{device_type}")
      Helper.backticks("xcrun instruments -w #{device_udid} &> /dev/null")

      UI.message("Uninstall application #{launcher_config.app_identifier}")
      Helper.backticks("xcrun simctl uninstall #{device_udid} #{launcher_config.app_identifier} &> /dev/null")
    end

    def erase_simulator(device_type)
      UI.verbose("Erasing #{device_type}...")
      device_udid = TestCommandGenerator.device_udid(device_type)

      UI.important("Erasing #{device_type}...")

      `xcrun simctl erase #{device_udid} &> /dev/null`
    end

    def localize_simulator(device_type, language, locale)
      device_udid = TestCommandGenerator.device_udid(device_type)
      if device_udid
        locale ||= language.sub("-", "_")
        plist = {
          AppleLocale: locale,
          AppleLanguages: [language]
        }
        UI.message("Localizing #{device_type} (AppleLocale=#{locale} AppleLanguages=[#{language}])")
        plist_path = "#{ENV['HOME']}/Library/Developer/CoreSimulator/Devices/#{device_udid}/data/Library/Preferences/.GlobalPreferences.plist"
        File.write(plist_path, Plist::Emit.dump(plist))
      end
    end

    def copy_simulator_logs(device_names, language, locale, launch_arguments)
      return unless launcher_config.output_simulator_logs

      detected_language = locale || language
      language_folder = File.join(launcher_config.output_directory, detected_language)

      device_names.each do |device_name|
        device = TestCommandGeneratorBase.find_device(device_name)
        components = [launch_arguments].delete_if { |a| a.to_s.length == 0 }

        UI.header("Collecting system logs #{device_name} - #{language}")
        log_identity = Digest::MD5.hexdigest(components.join("-"))
        FastlaneCore::Simulator.copy_logs(device, log_identity, language_folder)
      end
    end
  end
end
