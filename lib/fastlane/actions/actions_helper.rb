module Fastlane
  module Actions
    # Execute a shell command
    # This method will output the string and execute it
    def self.sh(command)
      Helper.log.info ["[SHELL]", command.yellow].join(': ')
      return `#{command}` unless Helper.is_test?
      return command # only when running tests
    end
  end
end