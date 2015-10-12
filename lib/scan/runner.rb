require 'pty'
require 'open3'
require 'fileutils'

module Scan
  class Runner
    def run
      test_app
    end

    def test_app
      command = TestCommandGenerator.generate
      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                              error: proc do |output|
                                                require 'pry'
                                                binding.pry
                                                # TODO: error handler
                                              end)

      ReportCollector.new.parse_raw_file(TestCommandGenerator.xcodebuild_log_path)

      # TODO: output
    end
  end
end
