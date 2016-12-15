require 'shellwords'
require 'plist'

module Snapshot
  class Runner
    # The number of times we failed on launching the simulator... sigh
    attr_accessor :number_of_retries_due_to_failing_simulator

    # All the errors we experience while running snapshot
    attr_accessor :collected_errors

    def work
      if File.exist?("./fastlane/snapshot.js") or File.exist?("./snapshot.js")
        UI.error "Found old snapshot configuration file 'snapshot.js'"
        UI.error "You updated to snapshot 1.0 which now uses UI Automation"
        UI.error "Please follow the migration guide: https://github.com/fastlane/fastlane/blob/master/snapshot/MigrationGuide.md"
        UI.error "And read the updated documentation: https://github.com/fastlane/fastlane/tree/master/snapshot"
        sleep 3 # to be sure the user sees this, as compiling clears the screen
      end

      Snapshot.config[:output_directory] = File.expand_path(Snapshot.config[:output_directory])

      verify_helper_is_current

      # Also print out the path to the used Xcode installation
      # We go 2 folders up, to not show "Contents/Developer/"
      values = Snapshot.config.values(ask: false)
      values[:xcode_path] = File.expand_path("../..", FastlaneCore::Helper.xcode_path)
      FastlaneCore::PrintTable.print_values(config: values, hide_keys: [], title: "Summary for snapshot #{Fastlane::VERSION}")

      clear_previous_screenshots if Snapshot.config[:clear_previous_screenshots]

      UI.success "Building and running project - this might take some time..."

      self.number_of_retries_due_to_failing_simulator = 0
      self.collected_errors = []
      results = {} # collect all the results for a nice table
      launch_arguments_set = config_launch_arguments
      Snapshot.config[:devices].each_with_index do |device, device_index|
        launch_arguments_set.each do |launch_arguments|
          Snapshot.config[:languages].each_with_index do |language, language_index|
            locale = nil
            if language.kind_of?(Array)
              locale = language[1]
              language = language[0]
            end
            results[device] ||= {}

            current_run = device_index * Snapshot.config[:languages].count + language_index + 1
            number_of_runs = Snapshot.config[:languages].count * Snapshot.config[:devices].count
            UI.message("snapshot run #{current_run} of #{number_of_runs}")

            results[device][language] = run_for_device_and_language(language, locale, device, launch_arguments)
          end
        end
      end

      print_results(results)

      UI.user_error!(self.collected_errors.join('; ')) if self.collected_errors.count > 0

      # Generate HTML report
      ReportsGenerator.new.generate

      # Clear the Derived Data
      unless Snapshot.config[:derived_data_path]
        FileUtils.rm_rf(TestCommandGenerator.derived_data_path)
      end
    end

    # This is its own method so that it can re-try if the tests fail randomly
    # @return true/false depending on if the tests succeded
    def run_for_device_and_language(language, locale, device, launch_arguments, retries = 0)
      return launch(language, locale, device, launch_arguments)
    rescue => ex
      UI.error ex.to_s # show the reason for failure to the user, but still maybe retry

      if retries < Snapshot.config[:number_of_retries]
        UI.important "Tests failed, re-trying #{retries + 1} out of #{Snapshot.config[:number_of_retries] + 1} times"
        run_for_device_and_language(language, locale, device, launch_arguments, retries + 1)
      else
        UI.error "Backtrace:\n\t#{ex.backtrace.join("\n\t")}" if $verbose
        self.collected_errors << ex
        raise ex if Snapshot.config[:stop_after_first_error]
        return false # for the results
      end
    end

    def config_launch_arguments
      launch_arguments = Array(Snapshot.config[:launch_arguments])
      # if more than 1 set of arguments, use a tuple with an index
      if launch_arguments.count == 1
        [launch_arguments]
      else
        launch_arguments.map.with_index { |e, i| [i, e] }
      end
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

    # Returns true if it succeded
    def launch(language, locale, device_type, launch_arguments)
      screenshots_path = TestCommandGenerator.derived_data_path
      FileUtils.rm_rf(File.join(screenshots_path, "Logs"))
      FileUtils.rm_rf(screenshots_path) if Snapshot.config[:clean]
      FileUtils.mkdir_p(screenshots_path)

      prefix = File.join(Dir.home, "Library/Caches/tools.fastlane")
      FileUtils.mkdir_p(prefix)
      File.write(File.join(prefix, "language.txt"), language)
      File.write(File.join(prefix, "locale.txt"), locale || "")
      File.write(File.join(prefix, "snapshot-launch_arguments.txt"), launch_arguments.last)

      # Kill and shutdown all currently running simulators so that the following settings
      # changes will be picked up when they are started again.
      Snapshot.kill_simulator # because of https://github.com/fastlane/snapshot/issues/337
      `xcrun simctl shutdown booted &> /dev/null`

      Fixes::SimulatorZoomFix.patch
      Fixes::HardwareKeyboardFix.patch

      if Snapshot.config[:erase_simulator] || Snapshot.config[:localize_simulator]
        erase_simulator(device_type)
        if Snapshot.config[:localize_simulator]
          localize_simulator(device_type, language, locale)
        end
      elsif Snapshot.config[:reinstall_app]
        # no need to reinstall if device has been erased
        uninstall_app(device_type)
      end

      add_media(device_type, :photo, Snapshot.config[:add_photos]) if Snapshot.config[:add_photos]
      add_media(device_type, :video, Snapshot.config[:add_videos]) if Snapshot.config[:add_videos]

      open_simulator_for_device(device_type)

      command = TestCommandGenerator.generate(device_type: device_type)

      if locale
        UI.header("#{device_type} - #{language} (#{locale})")
      else
        UI.header("#{device_type} - #{language}")
      end

      prefix_hash = [
        {
          prefix: "Running Tests: ",
          block: proc do |value|
            value.include?("Touching")
          end
        }
      ]

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                             prefix: prefix_hash,
                                            loading: "Loading...",
                                              error: proc do |output, return_code|
                                                ErrorHandler.handle_test_error(output, return_code)

                                                # no exception raised... that means we need to retry
                                                UI.error "Caught error... #{return_code}"

                                                self.number_of_retries_due_to_failing_simulator += 1
                                                if self.number_of_retries_due_to_failing_simulator < 20
                                                  launch(language, locale, device_type, launch_arguments)
                                                else
                                                  # It's important to raise an error, as we don't want to collect the screenshots
                                                  UI.crash!("Too many errors... no more retries...")
                                                end
                                              end)

      raw_output = File.read(TestCommandGenerator.xcodebuild_log_path)

      dir_name = locale || language

      return Collector.fetch_screenshots(raw_output, dir_name, device_type, launch_arguments.first)
    end

    def open_simulator_for_device(device_name)
      return unless ENV['FASTLANE_EXPLICIT_OPEN_SIMULATOR']

      device = TestCommandGenerator.find_device(device_name)
      FastlaneCore::Simulator.launch(device) if device
    end

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

    def clear_previous_screenshots
      UI.important "Clearing previously generated screenshots"
      path = File.join(Snapshot.config[:output_directory], "*", "*.png")
      Dir[path].each do |current|
        UI.verbose "Deleting #{current}"
        File.delete(current)
      end
    end

    def version_of_bundled_helper
      runner_dir = File.dirname(__FILE__)
      bundled_helper = File.read File.expand_path('../assets/SnapshotHelper.swift', runner_dir)
      current_version = bundled_helper.match(/\n.*SnapshotHelperVersion \[.+\]/)[0]

      ## Something like "// SnapshotHelperVersion [1.2]", but be relaxed about whitespace
      current_version.gsub(%r{^//\w*}, '').strip
    end

    # rubocop:disable Style/Next
    def verify_helper_is_current
      current_version = version_of_bundled_helper
      UI.verbose "Checking that helper files contain #{current_version}"

      helper_files = Update.find_helper
      helper_files.each do |path|
        content = File.read(path)

        unless content.include?(current_version)
          UI.error "Your '#{path}' is outdated, please run `snapshot update`"
          UI.error "to update your Helper file"
          UI.user_error!("Please update your Snapshot Helper file")
        end
      end
    end
    # rubocop:enable Style/Next
  end
end
