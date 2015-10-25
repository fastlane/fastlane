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

      FastlaneCore::PrintTable.print_values(config: Snapshot.config, hide_keys: [], title: "Summary")

      clear_previous_screenshots if Snapshot.config[:clear_previous_screenshots]

      Helper.log.info "Building and running project - this might take some time...".green

      self.number_of_retries = 0
      errors = []
      Snapshot.config[:devices].each do |device|
        Snapshot.config[:languages].each do |language|
          begin
            launch(language, device)
          rescue => ex
            Helper.log.error ex # we should to show right here as well
            errors << ex

            raise ex if Snapshot.config[:stop_after_first_error]
          end
        end
      end

      raise errors.join('; ') if errors.count > 0

      # Generate HTML report
      ReportsGenerator.new.generate
    end

    def launch(language, device_type)
      screenshots_path = TestCommandGenerator.derived_data_path
      FileUtils.rm_rf(screenshots_path)
      FileUtils.mkdir_p(screenshots_path)

      File.write("/tmp/language.txt", language)

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
                                                Helper.log.info "Cought error... #{return_code}".red

                                                self.number_of_retries += 1
                                                if self.number_of_retries < 20
                                                  launch(language, device_type)
                                                else
                                                  # It's important to raise an error, as we don't want to collect the screenshots
                                                  raise "Too many errors... no more retries...".red
                                                end
                                              end)

      raw_output = File.read(TestCommandGenerator.xcodebuild_log_path)
      Collector.fetch_screenshots(raw_output, language, device_type)
    end

    def clear_previous_screenshots
      Helper.log.info "Clearing previously generated screenshots".yellow
      path = File.join(".", Snapshot.config[:output_directory], "*", "*.png")
      Dir[path].each do |current|
        File.delete(current)
      end
    end
  end
end
