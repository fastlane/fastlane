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


      if config[:clear_previous_screenshots]
        Helper.log.info "Clearing output directory of screenshots at #{config[:output_directory]}".green
        files = Dir.glob(File.join('.', config[:output_directory], '**', '*.png'))
        File.delete(*files)
      end

      device_ext_storage = executor.execute(command: "adb shell echo \\$EXTERNAL_STORAGE",
                                          print_all: true,
                                      print_command: true)
      device_screenshots_path = File.join(device_ext_storage, config[:app_package_name])

      Helper.log.info "Cleaning screenshots directory on device".green
      executor.execute(command: "adb shell rm -rf #{device_screenshots_path}",
                     print_all: true,
                 print_command: true)

      Helper.log.info "Building APKs...".green
      executor.execute(command: "../gradlew assembleDebug assembleAndroidTest",
                     print_all: true,
                 print_command: true)
      
      # TODO this fails if the APK wasn't present at the point where we started running the command

      Helper.log.info "Installing APKs...".green
      executor.execute(command: "adb install -r #{config[:app_apk_path]}",
                     print_all: true,
                 print_command: true)
      executor.execute(command: "adb install -r #{config[:tests_apk_path]}",
                     print_all: true,
                 print_command: true)

      Helper.log.info "Granting the permission necessary to change locales on the device".green
      executor.execute(command: "adb shell pm grant #{config[:app_package_name]} android.permission.CHANGE_CONFIGURATION",
                     print_all: true,
                 print_command: true)

      device_api_version = executor.execute(command: "adb shell getprop ro.build.version.sdk",
                                          print_all: true,
                                      print_command: true).to_i

      if (device_api_version >= 23)
        Helper.log.info "Granting the permissions necessary to access device external storage".green
        executor.execute(command: "adb shell pm grant #{config[:app_package_name]} android.permission.WRITE_EXTERNAL_STORAGE",
                       print_all: true,
                   print_command: true)
        executor.execute(command: "adb shell pm grant #{config[:app_package_name]} android.permission.READ_EXTERNAL_STORAGE",
                       print_all: true,
                   print_command: true)
      end
      
      config[:locales].each do |locale|
        Helper.log.info "Running tests for locale: #{locale}".green

        # TODO need option(s) for specifying particular test classes/packages to run
        executor.execute(command: ["adb shell am instrument --no-window-animation -w",
                                   "-e testLocale #{locale.gsub("-", "_")}",
                                   "-e endingLocale en_US",
                                   "#{config[:tests_package_name]}/android.support.test.runner.AndroidJUnitRunner"].join(" \\\n"),
                       print_all: true,
                   print_command: true)
      end

      Helper.log.info "Pulling captured screenshots from the device".green
      executor.execute(command: "adb pull #{device_screenshots_path}/app_lens #{config[:output_directory]}",
                     print_all: true,
                 print_command: true)

      unless config[:skip_open_summary]
        Helper.log.info "Opening screenshots summary".green
        # TODO this isn't OK on any platform except Mac
        executor.execute(command: "open #{config[:output_directory]}/*/*.png",
                       print_all: false,
                   print_command: true)
      end

      print_results(results)

      raise errors.join('; ') if errors.count > 0

      # Generate HTML report
      # ReportsGenerator.new.generate

      # Clear the Derived Data
      # FileUtils.rm_rf(TestCommandGenerator.derived_data_path)
    end

    def print_results(results)
      return if results.count == 0

      rows = []
      results.each do |device, languages|
        current = [device]
        languages.each do |language, value|
          current << (value == true ? " 💚" : " ❌")
        end
        rows << current
      end

      params = {
        rows: rows,
        headings: ["Device"] + results.values.first.keys,
        title: "snapshot results"
      }
      puts ""
      puts Terminal::Table.new(params)
      puts ""
    end
  end
end
