require 'pty'
require 'open3'
require 'fileutils'
require 'terminal-table'

module Scan
  class Runner
    def run
      handle_results(test_app)
    end

    def test_app
      # We call this method, to be sure that all other simulators are killed
      # And a correct one is freshly launched. Switching between multiple simulator
      # in case the user specified multiple targets works with no issues
      # This way it's okay to just call it for the first simulator we're using for
      # the first test run
      open_simulator_for_device(Scan.devices.first) if Scan.devices

      command = TestCommandGenerator.generate
      prefix_hash = [
        {
          prefix: "Running Tests: ",
          block: proc do |value|
            value.include?("Touching")
          end
        }
      ]
      exit_status = 0
      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                             prefix: prefix_hash,
                                            loading: "Loading...",
                                              error: proc do |error_output|
                                                begin
                                                  exit_status = $?.exitstatus
                                                  ErrorHandler.handle_build_error(error_output)
                                                rescue => ex
                                                  SlackPoster.new.run({
                                                    build_errors: 1
                                                  })
                                                  raise ex
                                                end
                                              end)
      exit_status
    end

    def handle_results(tests_exit_status)
      result = TestResultParser.new.parse_result(File.read(Scan.cache[:temp_junit_report]))
      SlackPoster.new.run(result)

      if result[:failures] > 0
        failures_str = result[:failures].to_s.red
      else
        failures_str = result[:failures].to_s.green
      end

      puts Terminal::Table.new({
        title: "Test Results",
        rows: [
          ["Number of tests", result[:tests]],
          ["Number of failures", failures_str]
        ]
      })
      puts ""

      unless tests_exit_status == 0
        UI.user_error!("Test execution failed. Exit status: #{tests_exit_status}")
      end

      unless result[:failures] == 0
        UI.user_error!("Tests failed")
      end

      if Scan.cache[:open_html_report_path]
        `open --hide '#{Scan.cache[:open_html_report_path]}'`
      end
    end

    def open_simulator_for_device(device)
      return unless ENV['FASTLANE_EXPLICIT_OPEN_SIMULATOR']

      UI.message("Killing all running simulators")
      `killall Simulator &> /dev/null`

      FastlaneCore::Simulator.launch(device)
    end
  end
end
