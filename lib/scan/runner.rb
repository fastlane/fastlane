require 'pty'
require 'open3'
require 'fileutils'
require 'terminal-table'

module Scan
  class Runner
    def run
      test_app
      handle_results
    end

    def test_app
      command = TestCommandGenerator.generate
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
                                              error: proc do |error_output|
                                                begin
                                                  ErrorHandler.handle_build_error(error_output)
                                                rescue => ex
                                                  SlackPoster.new.run({
                                                    build_errors: 1
                                                  })
                                                  raise ex
                                                end
                                              end)
    end

    def handle_results
      # First, generate a JUnit report to get the number of tests
      require 'tempfile'
      output_file = Tempfile.new("junit_report")
      cmd = ReportCollector.new.generate_commands(TestCommandGenerator.xcodebuild_log_path,
                                                  types: 'junit',
                                                  output_file_name: output_file.path).values.last
      system(cmd)

      result = TestResultParser.new.parse_result(output_file.read)
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

      ReportCollector.new.parse_raw_file(TestCommandGenerator.xcodebuild_log_path)

      UI.user_error!("Tests failed") unless result[:failures] == 0
    end
  end
end
