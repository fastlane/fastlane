
module Screengrab
  class Runner
    NEEDED_PERMISSIONS = [
      'android.permission.READ_EXTERNAL_STORAGE',
      'android.permission.WRITE_EXTERNAL_STORAGE',
      'android.permission.CHANGE_CONFIGURATION'
    ].freeze

    attr_accessor :number_of_retries

    def initialize(executor = FastlaneCore::CommandExecutor,
                   config = Screengrab.config,
                   android_env = Screengrab.android_environment)

      @executor = executor
      @config = config
      @android_env = android_env
    end

    def run
      FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [], title: "Summary for screengrab #{Screengrab::VERSION}")

      app_apk_path = @config.fetch(:app_apk_path, ask: false)
      tests_apk_path = @config.fetch(:tests_apk_path, ask: false)
      discovered_apk_paths = Dir[File.join('**', '*.apk')]

      apk_paths_provided = app_apk_path && !app_apk_path.empty? && tests_apk_path && !tests_apk_path.empty?

      unless apk_paths_provided || discovered_apk_paths.any?
        UI.error 'No APK paths were provided and no APKs could be found'
        UI.error "Please provide APK paths with 'app_apk_path' and 'tests_apk_path' and make sure you have assembled APKs prior to running this command."
        return
      end

      test_classes_to_use = @config[:use_tests_in_classes]
      test_packages_to_use = @config[:use_tests_in_packages]

      if test_classes_to_use && test_classes_to_use.any? && test_packages_to_use && test_packages_to_use.any?
        UI.error "'use_tests_in_classes' and 'use_tests_in_packages' can not be combined. Please use one or the other."
        return
      end

      if (test_classes_to_use.nil? || test_classes_to_use.empty?) && (test_packages_to_use.nil? || test_packages_to_use.empty?)
        UI.important 'Limiting the test classes run by `screengrab` to just those that generate screenshots can make runs faster.'
        UI.important 'Consider using the :use_tests_in_classes or :use_tests_in_packages option, and organize your tests accordingly.'
      end

      device_type_dir_name = "#{@config[:device_type]}Screenshots"
      clear_local_previous_screenshots(device_type_dir_name)

      device_serial = select_device

      device_screenshots_paths = [
        determine_external_screenshots_path(device_serial),
        determine_internal_screenshots_path
      ]

      clear_device_previous_screenshots(device_serial, device_screenshots_paths)

      app_apk_path ||= select_app_apk(discovered_apk_paths)
      tests_apk_path ||= select_tests_apk(discovered_apk_paths)

      validate_apk(app_apk_path)

      install_apks(device_serial, app_apk_path, tests_apk_path)

      grant_permissions(device_serial)

      run_tests(device_serial, test_classes_to_use, test_packages_to_use)

      number_of_screenshots = pull_screenshots_from_device(device_serial, device_screenshots_paths, device_type_dir_name)

      open_screenshots_summary(device_type_dir_name)

      UI.success "Captured #{number_of_screenshots} screenshots! 📷✨"
    end

    def select_device
      devices = @executor.execute(command: "adb devices -l", print_all: true, print_command: true).split("\n")
      # the first output by adb devices is "List of devices attached" so remove that and any adb startup output
      # devices.reject! { |d| d.include?("List of devices attached") || d.include?("* daemon") || d.include?("unauthorized") || d.include?("offline") }
      devices.reject! do |device|
        ['unauthorized', 'offline', '* daemon', 'List of devices attached'].any? { |status| device.include? status }
      end

      UI.user_error! 'There are no connected and authorized devices or emulators' if devices.empty?

      devices.select! { |d| d.include?(@config[:specific_device]) } if @config[:specific_device]

      UI.user_error! "No connected devices matched your criteria: #{@config[:specific_device]}" if devices.empty?

      if devices.length > 1
        UI.important "Multiple connected devices, selecting the first one"
        UI.important "To specify which connected device to use, use the -s (specific_device) config option"
      end

      # grab the serial number. the lines of output can look like these:
      # 00c22d4d84aec525       device usb:2148663295X product:bullhead model:Nexus_5X device:bullhead
      # 192.168.1.100:5555       device usb:2148663295X product:bullhead model:Nexus_5X device:genymotion
      # emulator-5554       device usb:2148663295X product:bullhead model:Nexus_5X device:emulator
      devices[0].match(/^\S+/)[0]
    end

    def select_app_apk(discovered_apk_paths)
      UI.important "To not be asked about this value, you can specify it using 'app_apk_path'"
      UI.select('Select your debug app APK', discovered_apk_paths)
    end

    def select_tests_apk(discovered_apk_paths)
      UI.important "To not be asked about this value, you can specify it using 'tests_apk_path'"
      UI.select('Select your debug tests APK', discovered_apk_paths)
    end

    def clear_local_previous_screenshots(device_type_dir_name)
      if @config[:clear_previous_screenshots]
        UI.message "Clearing #{device_type_dir_name} within #{@config[:output_directory]}"

        # We'll clear the temporary directory where screenshots wind up after being pulled from
        # the device as well, in case those got stranded on a previous run/failure
        ['screenshots', device_type_dir_name].each do |dir_name|
          files = screenshot_file_names_in(@config[:output_directory], dir_name)
          File.delete(*files)
        end
      end
    end

    def screenshot_file_names_in(output_directory, device_type)
      Dir.glob(File.join('.', output_directory, '**', device_type, '*.png'), File::FNM_CASEFOLD)
    end

    def determine_external_screenshots_path(device_serial)
      device_ext_storage = @executor.execute(command: "adb -s #{device_serial} shell echo \\$EXTERNAL_STORAGE",
                                             print_all: true,
                                             print_command: true)
      File.join(device_ext_storage, @config[:app_package_name], 'screengrab')
    end

    def determine_internal_screenshots_path
      "/data/data/#{@config[:app_package_name]}/app_screengrab"
    end

    def clear_device_previous_screenshots(device_serial, device_screenshots_paths)
      UI.message 'Cleaning screenshots on device'

      device_screenshots_paths.each do |device_path|
        if_device_path_exists(device_serial, device_path) do |path|
          @executor.execute(command: "adb -s #{device_serial} shell rm -rf #{path}",
                            print_all: true,
                            print_command: true)
        end
      end
    end

    def validate_apk(app_apk_path)
      unless @android_env.aapt_path
        UI.important "The `aapt` command could not be found on your system, so your app APK could not be validated"
        return
      end

      UI.message 'Validating app APK'
      apk_permissions = @executor.execute(command: "#{@android_env.aapt_path} dump permissions #{app_apk_path}",
                                          print_all: true,
                                          print_command: true)

      missing_permissions = NEEDED_PERMISSIONS.reject { |needed| apk_permissions.include?(needed) }

      if missing_permissions.any?
        UI.user_error! "The needed permission(s) #{missing_permissions.join(', ')} could not be found in your app APK"
      end
    end

    def install_apks(device_serial, app_apk_path, tests_apk_path)
      UI.message 'Installing app APK'
      apk_install_output = @executor.execute(command: "adb -s #{device_serial} install -r #{app_apk_path}",
                        print_all: true,
                        print_command: true)
      UI.user_error! "App APK could not be installed" if apk_install_output.include?("Failure [")

      UI.message 'Installing tests APK'
      apk_install_output = @executor.execute(command: "adb -s #{device_serial} install -r #{tests_apk_path}",
                        print_all: true,
                        print_command: true)
      UI.user_error! "Tests APK could not be installed" if apk_install_output.include?("Failure [")
    end

    def grant_permissions(device_serial)
      UI.message 'Granting the permission necessary to change locales on the device'
      @executor.execute(command: "adb -s #{device_serial} shell pm grant #{@config[:app_package_name]} android.permission.CHANGE_CONFIGURATION",
                        print_all: true,
                        print_command: true)

      device_api_version = @executor.execute(command: "adb -s #{device_serial} shell getprop ro.build.version.sdk",
                                             print_all: true,
                                             print_command: true).to_i

      if device_api_version >= 23
        UI.message 'Granting the permissions necessary to access device external storage'
        @executor.execute(command: "adb -s #{device_serial} shell pm grant #{@config[:app_package_name]} android.permission.WRITE_EXTERNAL_STORAGE",
                          print_all: true,
                          print_command: true)
        @executor.execute(command: "adb -s #{device_serial} shell pm grant #{@config[:app_package_name]} android.permission.READ_EXTERNAL_STORAGE",
                          print_all: true,
                          print_command: true)
      end
    end

    def run_tests(device_serial, test_classes_to_use, test_packages_to_use)
      @config[:locales].each do |locale|
        UI.message "Running tests for locale: #{locale}"

        instrument_command = ["adb -s #{device_serial} shell am instrument --no-window-animation -w",
                              "-e testLocale #{locale.tr('-', '_')}",
                              "-e endingLocale #{@config[:ending_locale].tr('-', '_')}"]
        instrument_command << "-e class #{test_classes_to_use.join(',')}" if test_classes_to_use
        instrument_command << "-e package #{test_packages_to_use.join(',')}" if test_packages_to_use
        instrument_command << "#{@config[:tests_package_name]}/#{@config[:test_instrumentation_runner]}"

        test_output = @executor.execute(command: instrument_command.join(" \\\n"),
                                        print_all: true,
                                        print_command: true)

        UI.user_error! "Tests failed" if test_output.include?("FAILURES!!!")
      end
    end

    def pull_screenshots_from_device(device_serial, device_screenshots_paths, device_type_dir_name)
      UI.message "Pulling captured screenshots from the device"
      starting_screenshot_count = screenshot_file_names_in(@config[:output_directory], device_type_dir_name).length

      device_screenshots_paths.each do |device_path|
        if_device_path_exists(device_serial, device_path) do |path|
          @executor.execute(command: "adb -s #{device_serial} pull #{path} #{@config[:output_directory]}",
                            print_all: false,
                            print_command: true)
        end
      end

      # The SDK can't 100% determine what kind of device it is running on relative to the categories that
      # supply and Google Play care about (phone, 7" tablet, TV, etc.).
      #
      # Therefore, we'll move the pulled screenshots from their genericly named folder to one named by the
      # user provided device_type option value to match the directory structure that supply expects
      move_pulled_screenshots(device_type_dir_name)

      ending_screenshot_count = screenshot_file_names_in(@config[:output_directory], device_type_dir_name).length

      # Because we can't guarantee the screenshot output directory will be empty when we pull, we determine
      # success based on whether there are more screenshots there than when we started.
      if starting_screenshot_count == ending_screenshot_count
        UI.error "Make sure you've used Screengrab.screenshot() in your tests and that your expected tests are being run."
        UI.user_error! "No screenshots were detected 📷❌"
      end

      ending_screenshot_count - starting_screenshot_count
    end

    def move_pulled_screenshots(device_type_dir_name)
      # Glob pattern that finds the pulled screenshots directory for each locale
      # (Matches: fastlane/metadata/android/en-US/images/screenshots)
      screenshots_dir_pattern = File.join('.', @config[:output_directory], '**', "screenshots")

      Dir.glob(screenshots_dir_pattern, File::FNM_CASEFOLD).each do |screenshots_dir|
        src_screenshots = Dir.glob(File.join(screenshots_dir, '*.png'), File::FNM_CASEFOLD)

        # We move the screenshots by replacing the last segment of the screenshots directory path with
        # the device_type specific name
        #
        # (Moved to: fastlane/metadata/android/en-US/images/phoneScreenshots)
        dest_dir = File.join(File.dirname(screenshots_dir), device_type_dir_name)

        FileUtils.mkdir_p(dest_dir)
        FileUtils.cp_r(src_screenshots, dest_dir)
        FileUtils.rm_r(screenshots_dir)
        UI.success "Screenshots copied to #{dest_dir}"
      end
    end

    # Some device commands fail if executed against a device path that does not exist, so this helper method
    # provides a way to conditionally execute a block only if the provided path exists on the device.
    def if_device_path_exists(device_serial, device_path)
      return if @executor.execute(command: "adb -s #{device_serial} shell ls #{device_path}",
                                  print_all: false,
                                  print_command: false).include?('No such file')

      yield device_path
    end

    def open_screenshots_summary(device_type_dir_name)
      unless @config[:skip_open_summary]
        UI.message "Opening screenshots summary"
        # MCF: this isn't OK on any platform except Mac
        @executor.execute(command: "open #{@config[:output_directory]}/*/images/#{device_type_dir_name}/*.png",
                          print_all: false,
                          print_command: true)
      end
    end
  end
end
