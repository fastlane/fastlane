require 'pty'
require 'shellwords'

module Snapshot
  class Runner
    attr_accessor :errors

    def work
      self.errors = []

      Helper.log.info "Building and running project - this might take some time...".green

      errors = []
      Snapshot.config[:devices].each do |device|
        Snapshot.config[:languages].each do |language|
          begin
            launch(language, device)
          rescue => ex
            errors << ex
          end
        end
      end

      raise errors.join('; ') if errors.count > 0
    end

    def launch(language, device_type)
      screenshots_path = "/tmp/snapshot/"
      FileUtils.rm_rf(screenshots_path)
      FileUtils.mkdir_p(screenshots_path)

      File.write("/tmp/language.txt", language)

      command = TestCommandGenerator.generate(device_type: device_type)

      Helper.log_alert("#{device_type.name} - #{language}")

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                              error: proc do |output, return_code|
                                                ErrorHandler.handle_test_error(output, return_code)
                                                # no exception raised... that means we need to retry
                                                launch(language, device_type)
                                              end)

      raw_output = File.read(TestCommandGenerator.xcodebuild_log_path)
      fetch_screenshots(raw_output, language, device_type)
    end

    def fetch_screenshots(output, language, device_type)
      containing = File.join(TestCommandGenerator.derived_data_path, "Logs", "Test", "Attachments")
      screenshots = Dir.glob(File.join(containing, "*.png")).collect do |path|
        {
          path: path,
          modified: File.mtime(path)
        }
      end

      output.scan(/snapshot: (.*) \((.*)\)/).each do |current|
        name = current[0]
        time_stamp = Time.at(current[1].to_i)

        # Find the closest screenshot taken at this time
        closest = nil
        screenshots.each do |screenshot|
          if !closest || (screenshot[:modified] - time_stamp > closest[:modified] - time_stamp)
            closest = screenshot
          end
        end

        FileUtils.cp(closest[:path], "./#{name} - #{language} - #{device_type.name}.png")
      end
    end
  end
end
