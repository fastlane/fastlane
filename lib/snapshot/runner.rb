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
        UI.error "Please follow the migration guide: https://github.com/fastlane/snapshot/blob/master/MigrationGuide.md"
        UI.error "And read the updated documentation: https://github.com/fastlane/snapshot"
        sleep 3 # to be sure the user sees this, as compiling clears the screen
      end

      verify_helper_is_current

      FastlaneCore::PrintTable.print_values(config: Snapshot.config, hide_keys: [], title: "Summary for snapshot #{Snapshot::VERSION}")

      clear_previous_screenshots if Snapshot.config[:clear_previous_screenshots]

      UI.success "Building and running project - this might take some time..."

      self.number_of_retries_due_to_failing_simulator = 0
      self.collected_errors = []
      results = {} # collect all the results for a nice table
      launch_arguments_set = config_launch_arguments
      Snapshot.config[:devices].each do |device|
        launch_arguments_set.each do |launch_arguments|
          Snapshot.config[:languages].each do |language|
            results[device] ||= {}

            results[device][language] = run_for_device_and_language(language, device, launch_arguments)
          end
        end
      end

      print_results(results)

      raise self.collected_errors.join('; ') if self.collected_errors.count > 0

      # Generate HTML report
      ReportsGenerator.new.generate

      # Clear the Derived Data
      FileUtils.rm_rf(TestCommandGenerator.derived_data_path)
    end

    # This is its own method so that it can re-try if the tests fail randomly
    # @return true/false depending on if the tests succeded
    def run_for_device_and_language(language, device, launch_arguments, retries = 0)
      return launch(language, device, launch_arguments)
    rescue => ex
      UI.error ex.to_s # show the reason for failure to the user, but still maybe retry

      if retries < Snapshot.config[:number_of_retries]
        UI.important "Tests failed, re-trying #{retries + 1} out of #{Snapshot.config[:number_of_retries] + 1} times"
        run_for_device_and_language(language, device, launch_arguments, retries + 1)
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
    def launch(language, device_type, launch_arguments)
      screenshots_path = TestCommandGenerator.derived_data_path
      FileUtils.rm_rf(File.join(screenshots_path, "Logs"))
      FileUtils.rm_rf(screenshots_path) if Snapshot.config[:clean]
      FileUtils.mkdir_p(screenshots_path)

      File.write("/tmp/language.txt", language)
      File.write("/tmp/snapshot-launch_arguments.txt", launch_arguments.last)

      Fixes::SimulatorZoomFix.patch

      Snapshot.kill_simulator # because of https://github.com/fastlane/snapshot/issues/337
      `xcrun simctl shutdown booted &> /dev/null`

      uninstall_app(device_type) if Snapshot.config[:reinstall_app]

      command = TestCommandGenerator.generate(device_type: device_type)

      UI.header("#{device_type} - #{language}")

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
                                                  launch(language, device_type, launch_arguments)
                                                else
                                                  # It's important to raise an error, as we don't want to collect the screenshots
                                                  UI.crash!("Too many errors... no more retries...")
                                                end
                                              end)

      raw_output = File.read(TestCommandGenerator.xcodebuild_log_path)
      return Collector.fetch_screenshots(raw_output, language, device_type, launch_arguments.first)
    end

    def uninstall_app(device_type)
      UI.verbose "Uninstalling app '#{Snapshot.config[:app_identifier]}' from #{device_type}..."
      Snapshot.config[:app_identifier] ||= ask("App Identifier: ")
      device_udid = TestCommandGenerator.device_udid(device_type)

      UI.message "Launch Simulator #{device_type}"
      Helper.backticks("xcrun instruments -w #{device_udid} &> /dev/null")

      UI.message "Uninstall application #{Snapshot.config[:app_identifier]}"
      Helper.backticks("xcrun simctl uninstall #{device_udid} #{Snapshot.config[:app_identifier]} &> /dev/null")
    end

    def clear_previous_screenshots
      UI.important "Clearing previously generated screenshots"
      path = File.join(".", Snapshot.config[:output_directory], "*", "*.png")
      Dir[path].each do |current|
        File.delete(current)
      end
    end

    # rubocop:disable Style/Next
    def verify_helper_is_current
      helper_files = Update.find_helper
      helper_files.each do |path|
        content = File.read(path)

        if content.include?("start.pressForDuration(0, thenDragToCoordinate: finish)")
          UI.error "Your '#{path}' is outdated, please run `snapshot update`"
          UI.error "to update your Helper file"
          UI.user_error!("Please update your Snapshot Helper file")
        end
      end
    end
    # rubocop:enable Style/Next
  end
end
