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

    # Is the required gem installed on the current machine
    def self.gem_available?(name)
      return true if Helper.is_test?
      
      Gem::Specification.find_by_name(name)
    rescue Gem::LoadError
      false
    rescue
      Gem.available?(name)
    end

    # This will throw an exception if gem is missing
    def self.need_gem!(name)
      unless self.gem_available?(name)
        raise "Gem '#{name}' is not installed. Run `sudo gem install #{name}` to install it. More information: https://github.com/KrauseFx/#{name}.".red
      end
    end
  end
end