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
      exc = nil

      begin
        yield
      rescue => ex
        exc = ex
        error = caller.join("\n") + "\n\n" + ex.to_s
      end
    ensure
      # This is also called, when the block has a return statement
      duration = Time.now - start

      self.executed_actions << {
        name: step_name,
        error: error,
        time: duration,
        started: start
        # output: captured_output
      }
      raise exc if exc
    end

    # Execute a shell command
    # This method will output the string and execute it
    def self.sh(command)
      self.execute_action(command) do
        return sh_no_action(command)
      end
    end

    # Same as self.sh, but without wrapping it into its own test case. Call this from other custom actions
    def self.sh_no_action(command)
      command = command.join(" ") if command.kind_of?Array # since it's an array of one element when running from the Fastfile
      Helper.log.info ["[SHELL COMMAND]", command.yellow].join(': ')

      result = ""
      unless Helper.is_test?

        PTY.spawn(command) do |stdin, stdout, pid|
          stdin.each do |line|
            Helper.log.info ["[SHELL OUTPUT]", line.strip].join(': ')
            result << line
          end

          Process.wait(pid)
        end

        if $?.exitstatus.to_i != 0
          raise "Exit status of command '#{command}' was #{$?.exitstatus.to_s} instead of 0. Build failed."
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
  end
end