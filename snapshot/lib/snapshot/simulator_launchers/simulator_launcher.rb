module Snapshot
  class SimulatorLauncher
    attr_accessor :collected_errors

    def initialize
      @collected_errors = []
    end

    def prepare_for_launch(language, locale, launch_arguments)
      screenshots_path = TestCommandGenerator.derived_data_path
      FileUtils.rm_rf(File.join(screenshots_path, "Logs"))
      FileUtils.rm_rf(screenshots_path) if Snapshot.config[:clean]
      FileUtils.mkdir_p(screenshots_path)

      FileUtils.mkdir_p(CACHE_DIR)
      FileUtils.mkdir_p(SCREENSHOTS_DIR)

      File.write(File.join(CACHE_DIR, "language.txt"), language)
      File.write(File.join(CACHE_DIR, "locale.txt"), locale || "")
      File.write(File.join(CACHE_DIR, "snapshot-launch_arguments.txt"), launch_arguments.last)

      prepare_simulators_for_launch(language: language, locale: locale)
    end

    def prepare_simulators_for_launch(language: nil, locale: nil)
      # Kill and shutdown all currently running simulators so that the following settings
      # changes will be picked up when they are started again.
      Snapshot.kill_simulator # because of https://github.com/fastlane/snapshot/issues/337
      `xcrun simctl shutdown booted &> /dev/null`

      Fixes::SimulatorZoomFix.patch
      Fixes::HardwareKeyboardFix.patch

      devices = Snapshot.config[:devices] || []
      devices.each do |type|
        if Snapshot.config[:erase_simulator] || Snapshot.config[:localize_simulator]
          erase_simulator(type)
          if Snapshot.config[:localize_simulator]
            localize_simulator(type, language, locale)
          end
        elsif Snapshot.config[:reinstall_app]
          # no need to reinstall if device has been erased
          uninstall_app(type)
        end
      end
    end

    # TODO: Check if this works with concurrent sims
    # pass an array of device types
    def add_media(device_type, media_type, paths)
      media_type = media_type.to_s

      UI.verbose "Adding #{media_type}s to #{device_type}..."
      device_udid = TestCommandGenerator.device_udid(device_type)

      UI.message "Launch Simulator #{device_type}"
      Helper.backticks("xcrun instruments -w #{device_udid} &> /dev/null")

      paths.each do |path|
        UI.message "Adding '#{path}'"
        Helper.backticks("xcrun simctl add#{media_type} #{device_udid} #{path.shellescape} &> /dev/null")
      end
    end

    # TODO: Can these move to a simulator object?
    def uninstall_app(device_type)
      UI.verbose "Uninstalling app '#{Snapshot.config[:app_identifier]}' from #{device_type}..."
      Snapshot.config[:app_identifier] ||= UI.input("App Identifier: ")
      device_udid = TestCommandGenerator.device_udid(device_type)

      UI.message "Launch Simulator #{device_type}"
      Helper.backticks("xcrun instruments -w #{device_udid} &> /dev/null")

      UI.message "Uninstall application #{Snapshot.config[:app_identifier]}"
      Helper.backticks("xcrun simctl uninstall #{device_udid} #{Snapshot.config[:app_identifier]} &> /dev/null")
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
        UI.message "Localizing #{device_type} (AppleLocale=#{locale} AppleLanguages=[#{language}])"
        plist_path = "#{ENV['HOME']}/Library/Developer/CoreSimulator/Devices/#{device_udid}/data/Library/Preferences/.GlobalPreferences.plist"
        File.write(plist_path, Plist::Emit.dump(plist))
      end
    end
  end
end
