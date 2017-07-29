module Fastlane
  module Actions
    # Execute a shell command
    # This method will output the string and execute it
    # Just an alias for sh_no_action
    # When running this in tests, it will return the actual command instead of executing it
    # @param log [Boolean] should fastlane print out the executed command
    # @param error_callback [Block] a callback invoked with the command output if there is a non-zero exit status
    def self.sh(command, log: true, error_callback: nil)
      sh_control_output(command, print_command: log, print_command_output: log, error_callback: error_callback)
    end

    def self.sh_no_action(command, log: true, error_callback: nil)
      sh_control_output(command, print_command: log, print_command_output: log, error_callback: error_callback)
    end

    # @param command [String] The command to be executed
    # @param print_command [Boolean] Should we print the command that's being executed
    # @param print_command_output [Boolean] Should we print the command output during execution
    # @param error_callback [Block] A block that's called if the command exits with a non-zero status
    def self.sh_control_output(command, print_command: true, print_command_output: true, error_callback: nil)
      print_command = print_command_output = true if $troubleshoot
      # Set the encoding first, the user might have set it wrong
      previous_encoding = [Encoding.default_external, Encoding.default_internal]
      Encoding.default_external = Encoding::UTF_8
      Encoding.default_internal = Encoding::UTF_8

      command = command.join(' ') if command.kind_of?(Array) # since it's an array of one element when running from the Fastfile
      UI.command(command) if print_command

      result = ''
      if Helper.sh_enabled?
        exit_status = nil
        IO.popen(command, err: [:child, :out]) do |io|
          io.sync = true
          io.each do |line|
            UI.command_output(line.strip) if print_command_output
            result << line
          end
          io.close
          exit_status = $?.exitstatus
        end

        if exit_status != 0
          message = if print_command
                      "Exit status of command '#{command}' was #{exit_status} instead of 0."
                    else
                      "Shell command exited with exit status #{exit_status} instead of 0."
                    end
          message += "\n#{result}" if print_command_output

          if error_callback
            UI.error(message)
            error_callback.call(result)
          else
            UI.shell_error!(message)
          end
        end
      else
        result << command # only for the tests
      end

      result
    rescue => ex
      raise ex
    ensure
      Encoding.default_external = previous_encoding.first
      Encoding.default_internal = previous_encoding.last
    end
  end
end
