require 'pty'
require 'open3'
require 'fileutils'

module Scan
  class Runner
    def run
      test_app
    end

    def test_app
      command = BuildCommandGenerator.generate
      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                              error: proc do |output|
                                                require 'pry'
                                                binding.pry
                                              end)

      # TODO: output
    end
  end
end
