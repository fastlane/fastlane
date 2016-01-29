module Fastlane
  module Actions
    # Execute a shell command
    # This method will output the string and execute it
    # Just an alias for sh_no_action
    # When running this in tests, it will return the actual command instead of executing it
    # @param log [boolean] should fastlane print out the executed command
    def self.sh(command, log: true)
      sh_no_action(command, log: log)
    end

    def self.sh_no_action(command, log: true)
      # Set the encoding first, the user might have set it wrong
      previous_encoding = [Encoding.default_external, Encoding.default_internal]
      Encoding.default_external = Encoding::UTF_8
      Encoding.default_internal = Encoding::UTF_8

      command = command.join(' ') if command.kind_of?(Array) # since it's an array of one element when running from the Fastfile
      UI.command(command) if log

      result = ''
      if Helper.test?
        result << command # only for the tests
      else
        exit_status = nil
        IO.popen(command, err: [:child, :out]) do |io|
          io.sync = true
          io.each do |line|
            UI.command_output(line.strip) if log
            result << line
          end
          io.close
          exit_status = $?.exitstatus
        end

        if exit_status != 0
          # this will also append the output to the exception
          message = "Exit status of command '#{command}' was #{exit_status} instead of 0."
          message += "\n#{result}" if log
          UI.crash!(message)
        end
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
