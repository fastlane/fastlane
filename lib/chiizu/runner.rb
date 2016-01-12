module Chiizu
  class Runner
    attr_accessor :number_of_retries

    def work
      config = Chiizu.config

      FastlaneCore::PrintTable.print_values(config: config, hide_keys: [], title: "Summary for chiizu #{Chiizu::VERSION}")

      self.number_of_retries = 0
      errors = []
      results = {} # collect all the results for a nice table

      executor = FastlaneCore::CommandExecutor

      app_apk_path = config.fetch(:app_apk_path, ask: false)
      tests_apk_path = config.fetch(:tests_apk_path, ask: false)
      discovered_apk_paths = Dir[File.join('**', '*.apk')]

      apk_paths_provided = app_apk_path && !app_apk_path.empty? && tests_apk_path && !tests_apk_path.empty?
      
      unless apk_paths_provided || discovered_apk_paths.any?
        UI.error 'No APK paths were provided and no APKs could be found'
        UI.error "Please provide APK paths with 'app_apk_path' and 'tests_apk_path' and make sure you have assembled APKs prior to running this command."
        return
      end

      test_classes_to_use = config[:use_tests_in_classes]
      test_packages_to_use = config[:use_tests_in_packages]

      if test_classes_to_use && test_classes_to_use.any? && test_packages_to_use && test_packages_to_use.any?
        UI.error "'use_tests_in_classes' and 'use_tests_in_packages' can not be combined. Please use one or the other."
        return
      end

      devices = executor.execute(command: "adb devices -l", print_all: true, print_command: true).split("\n")
      # the first output by adb devices is "List of devices attached" so remove that
      devices = devices.drop(1)

      if devices.empty?
        UI.error 'There are no connected devices or emulators'
        return
      end

      devices.select! { |d| d.include?(config[:specific_device]) } if config[:specific_device]
      if devices.empty?
        UI.error "No connected devices matched your criteria: #{config[:specific_device]}"
        return
      end

      if devices.length > 1
        UI.important "Multiple connected devices, selecting the first one"
        UI.important "To specify which connected device to use, use the -s (specific_device) config option"
      end

      # grab the serial number. the line looks like this:
      # 00c22d4d84aec525       device usb:2148663295X product:bullhead model:Nexus_5X device:bullhead
      device_serial = devices[0].match(/^[\w]+/)[0]

      if config[:clear_previous_screenshots]
        UI.message "Clearing output directory of screenshots at #{config[:output_directory]}"
        files = Dir.glob(File.join('.', config[:output_directory], '**', '*.png'))
        File.delete(*files)
      end

      device_ext_storage = executor.execute(command: "adb -s #{device_serial} shell echo \\$EXTERNAL_STORAGE",
                                          print_all: true,
                                      print_command: true)
      device_screenshots_path = File.join(device_ext_storage, config[:app_package_name])

      # TODO need to handle commands failing

      UI.message 'Cleaning screenshots directory on device'
      executor.execute(command: "adb -s #{device_serial} shell rm -rf #{device_screenshots_path}",
                     print_all: true,
                 print_command: true)

      unless app_apk_path
        UI.important "To not be asked about this value, you can specify it using 'app_apk_path'"
        app_apk_path = UI.select('Select your debug app APK', discovered_apk_paths)
      end

      UI.message 'Installing app APK'
      executor.execute(command: "adb -s #{device_serial} install -r #{app_apk_path}",
                     print_all: true,
                 print_command: true)

      unless tests_apk_path
        UI.important "To not be asked about this value, you can specify it using 'tests_apk_path'"
        tests_apk_path = UI.select('Select your debug tests APK', discovered_apk_paths)
      end

      UI.message 'Installing tests APK'
      executor.execute(command: "adb -s #{device_serial} install -r #{tests_apk_path}",
                     print_all: true,
                 print_command: true)

      UI.message 'Granting the permission necessary to change locales on the device'
      executor.execute(command: "adb -s #{device_serial} shell pm grant #{config[:app_package_name]} android.permission.CHANGE_CONFIGURATION",
                     print_all: true,
                 print_command: true)

      device_api_version = executor.execute(command: "adb -s #{device_serial} shell getprop ro.build.version.sdk",
                                          print_all: true,
                                      print_command: true).to_i

      if (device_api_version >= 23)
        UI.message 'Granting the permissions necessary to access device external storage'
        executor.execute(command: "adb -s #{device_serial} shell pm grant #{config[:app_package_name]} android.permission.WRITE_EXTERNAL_STORAGE",
                       print_all: true,
                   print_command: true)
        executor.execute(command: "adb -s #{device_serial} shell pm grant #{config[:app_package_name]} android.permission.READ_EXTERNAL_STORAGE",
                       print_all: true,
                   print_command: true)
      end
      
      config[:locales].each do |locale|
        UI.message "Running tests for locale: #{locale}"

        instrument_command = ["adb -s #{device_serial} shell am instrument --no-window-animation -w",
                              "-e testLocale #{locale.gsub("-", "_")}",
                              "-e endingLocale #{config[:ending_locale].gsub("-", "_")}"]
        instrument_command << "-e class #{test_classes_to_use.join(',')}" if test_classes_to_use
        instrument_command << "-e package #{test_packages_to_use.join(',')}" if test_packages_to_use
        instrument_command << "#{config[:tests_package_name]}/#{config[:test_instrumentation_runner]}"

        executor.execute(command: instrument_command.join(" \\\n"),
                       print_all: true,
                   print_command: true)
      end

      UI.message "Pulling captured screenshots from the device"
      executor.execute(command: "adb -s #{device_serial} pull #{device_screenshots_path}/app_lens #{config[:output_directory]}",
                     print_all: true,
                 print_command: true)

      unless config[:skip_open_summary]
        UI.message "Opening screenshots summary"
        # TODO this isn't OK on any platform except Mac
        executor.execute(command: "open #{config[:output_directory]}/*/*.png",
                       print_all: false,
                   print_command: true)
      end

      raise errors.join('; ') if errors.count > 0

      # Clear the Derived Data
      # FileUtils.rm_rf(TestCommandGenerator.derived_data_path)

      UI.success 'Your screenshots are ready! 📷✨'
    end
  end
end
