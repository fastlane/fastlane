require 'shellwords'
require 'plist'

module Snapshot
  class Runner
    attr_accessor :number_of_retries

    def work
      if File.exist?("./fastlane/snapshot.js") or File.exist?("./snapshot.js")
        Helper.log.warn "Found old snapshot configuration file 'snapshot.js'".red
        Helper.log.warn "You updated to snapshot 1.0 which now uses UI Automation".red
        Helper.log.warn "Please follow the migration guide: https://github.com/KrauseFx/snapshot/blob/master/MigrationGuide.md".red
        Helper.log.warn "And read the updated documentation: https://github.com/KrauseFx/snapshot".red
        sleep 3 # to be sure the user sees this, as compiling clears the screen
      end

      verify_helper_is_current

      FastlaneCore::PrintTable.print_values(config: Snapshot.config, hide_keys: [], title: "Summary for snapshot #{Snapshot::VERSION}")

      clear_previous_screenshots if Snapshot.config[:clear_previous_screenshots]

      Helper.log.info "Building and running project - this might take some time...".green

      self.number_of_retries = 0
      errors = []
      results = {} # collect all the results for a nice table
      launch_arguments_set = config_launch_arguments
      Snapshot.config[:devices].each do |device|
        launch_arguments_set.each do |launch_arguments|
          Snapshot.config[:languages].each do |language|
            results[device] ||= {}

            begin
              launch(language, device, launch_arguments)
              results[device][language] = true
            rescue => ex
              Helper.log.error ex # we should to show right here as well
              errors << ex
              results[device][language] = false
              raise ex if Snapshot.config[:stop_after_first_error]
            end
          end
        end
      end

      print_results(results)

      raise errors.join('; ') if errors.count > 0

      # Generate HTML report
      ReportsGenerator.new.generate

      # Clear the Derived Data
      FileUtils.rm_rf(TestCommandGenerator.derived_data_path)
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

      Helper.log_alert("#{device_type} - #{language}")

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
                                                Helper.log.info "Caught error... #{return_code}".red

                                                self.number_of_retries += 1
                                                if self.number_of_retries < 20
                                                  launch(language, device_type, launch_arguments)
                                                else
                                                  # It's important to raise an error, as we don't want to collect the screenshots
                                                  raise "Too many errors... no more retries...".red
                                                end
                                              end)

      raw_output = File.read(TestCommandGenerator.xcodebuild_log_path)
      Collector.fetch_screenshots(raw_output, language, device_type, launch_arguments.first)
    end

    def uninstall_app(device_type)
      Helper.log.debug "Uninstalling app '#{Snapshot.config[:app_identifier]}' from #{device_type}..."
      Snapshot.config[:app_identifier] ||= ask("App Identifier: ")
      device_udid = TestCommandGenerator.device_udid(device_type)

      Helper.log.info "Launch Simulator #{device_type}".yellow
      `xcrun instruments -w #{device_udid} &> /dev/null`

      Helper.log.info "Uninstall application #{Snapshot.config[:app_identifier]}".yellow
      `xcrun simctl uninstall #{device_udid} #{Snapshot.config[:app_identifier]} &> /dev/null`
    end

    def clear_previous_screenshots
      Helper.log.info "Clearing previously generated screenshots".yellow
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
          Helper.log.error "Your '#{path}' is outdated, please run `snapshot update`".red
          Helper.log.error "to update your Helper file".red
          raise "Please update your Snapshot Helper file".red
        end
      end
    end
    # rubocop:enable Style/Next
  end
end
