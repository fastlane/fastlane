require 'pty'

module Fastlane
  module Actions
    def self.executed_actions
      @@executed_actions ||= []
    end

    # Pass a block which should be tracked. One block = one testcase
    # @param step_name (String) the name of the currently built code (e.g. snapshot, sigh, ...)
    def self.execute_action(step_name)
      raise "No block given".red unless block_given?
      
      start = Time.now
      error = nil

      begin
        yield
      rescue Exception => ex
        error = caller.join("\n") + "\n\n" + ex.to_s
        puts error
      end
      duration = Time.now - start

      self.executed_actions << {
        name: step_name,
        error: error,
        time: duration
        # output: captured_output
      }
    end

    # Execute a shell command
    # This method will output the string and execute it
    def self.sh(command)    
      self.execute_action(command) do
        sh_no_action(command)
      end
    end

    # Same as self.sh, but without wrapping it into its own test case. Call this from other custom actions
    def self.sh_no_action(command)
      Helper.log.info ["[SHELL COMMAND]", command.yellow].join(': ')

      result = ""
      unless Helper.is_test?

        PTY.spawn(command) do |stdin, stdout, pid|
          stdin.each do |line|
            Helper.log.info ["[SHELL OUTPUT]", line.strip].join(': ')
            result << line
          end
        end

      else
        result << command # only when running tests
      end

      return result
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