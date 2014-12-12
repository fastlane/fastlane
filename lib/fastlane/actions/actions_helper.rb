require 'pty'

module Fastlane
  module Actions
    # Execute a shell command
    # This method will output the string and execute it
    def self.sh(commands)
      commands = [commands] if commands.kind_of?String

      results = []
      commands.each do |command|
        Helper.log.info ["[SHELL COMMAND]", command.yellow].join(': ')

        unless Helper.is_test?

          PTY.spawn(command) do |stdin, stdout, pid|
            stdin.each do |line|
              Helper.log.info ["[SHELL OUTPUT]", line.strip].join(': ')
              results << line
            end
          end

        else
          results << command # only when running tests
        end
      end

      return results
    end
  end
end