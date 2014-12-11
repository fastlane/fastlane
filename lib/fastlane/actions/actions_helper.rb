module Fastlane
  module Actions
    # Execute a shell command
    # This method will output the string and execute it
    def self.sh(command)
      Helper.log.info ["[SHELL]", command.yellow].join(': ')
      `#{command}`
    end
  end
end