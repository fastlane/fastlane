require 'pty'
require 'open3'
require 'fileutils'
require 'terminal-table'

module Scan
  class Runner
    def run
      test_app
    end

    def test_app
      command = TestCommandGenerator.generate
      output = FastlaneCore::CommandExecutor.execute(command: command,
                                                  print_all: true,
                                              print_command: true,
                                                      error: proc do |output|
                                                        ErrorHandler.handle_build_error(output)
                                                      end)
      result = TestResultParser.new.parse_result(output)
      puts Terminal::Table.new({
        title: "Test Results",
        rows: [
          ["Number of tests", result[:tests]],
          ["Number of failures", result[:failures]],
          ["Duration (in seconds)", result[:duration]]
        ]
      })
      puts ""

      ReportCollector.new.parse_raw_file(TestCommandGenerator.xcodebuild_log_path)

      # TODO: output
    end
  end
end
