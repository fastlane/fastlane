require 'pty'
require 'shellwords'
require 'plist'

module Snapshot
  class Runner
    attr_accessor :errors

    def work
      clear_previous_screenshots if Snapshot.config[:clear_previous_screenshots]

      self.errors = []

      Helper.log.info "Building and running project - this might take some time...".green

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
    end

    def launch(language, device_type)
      screenshots_path = TestCommandGenerator.derived_data_path
      FileUtils.rm_rf(screenshots_path)
      FileUtils.mkdir_p(screenshots_path)

      File.write("/tmp/language.txt", language)

      command = TestCommandGenerator.generate(device_type: device_type)

      Helper.log_alert("#{device_type} - #{language}")

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                             prefix: {
                                                "Touching" => "Running Tests: "
                                              },
                                              error: proc do |output, return_code|
                                                ErrorHandler.handle_test_error(output, return_code)

                                                # no exception raised... that means we need to retry
                                                Helper.log.info "Cought error... #{return_code}".red
                                                launch(language, device_type)
                                              end)

      raw_output = File.read(TestCommandGenerator.xcodebuild_log_path)
      Collector.fetch_screenshots(raw_output, language, device_type)
    end

    def clear_previous_screenshots
      Helper.log.info "Clearing previously generated screenshots".yellow
      path = File.join(".", Snapshot.config[:output_directory], "*", "*.png")
      Dir[path].each do |path|
        File.delete(path)
      end
    end
  end
end
