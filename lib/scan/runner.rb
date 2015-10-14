require 'pty'
require 'open3'
require 'fileutils'
require 'terminal-table'

module Scan
  class Runner
    def run
      output = test_app
      handle_results(output)
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
      output = FastlaneCore::CommandExecutor.execute(command: command,
                                                  print_all: true,
                                              print_command: true,
                                                     prefix: prefix_hash,
                                                    loading: "Loading...",
                                                      error: proc do |error_output|
                                                        ErrorHandler.handle_build_error(error_output)
                                                      end)

      return output
    end

    def handle_results(_output)
      # First, generate a JUnit report to get the number of tests
      require 'tempfile'
      output_file = Tempfile.new("junit_report")
      cmd = ReportCollector.new.generate_commands(TestCommandGenerator.xcodebuild_log_path,
                                                  types: 'junit',
                                                  output_file_name: output_file.path).values.last
      system(cmd)

      result = TestResultParser.new.parse_result(output_file.read)

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
    end
  end
end
