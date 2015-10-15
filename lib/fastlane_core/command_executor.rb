module FastlaneCore
  # Executes commands and takes care of error handling and more
  class CommandExecutor
    class << self
      # @param command [String] The command to be executed
      # @param print_all [Boolean] Do we want to print out the command output while running?
      # @param print_command [Boolean] Should we print the command that's being executed
      # @param error [Block] A block that's called if an error occurs
      # @param prefix [Array] An array containg a prefix + block which might get applied to the output
      # @param loading [String] A loading string that is shown before the first output
      # @return [String] All the output as string
      def execute(command: nil, print_all: false, print_command: true, error: nil, prefix: nil, loading: nil)
        print_all = true if $verbose
        prefix ||= {}

        output = []
        command = command.join(" ") if command.kind_of?(Array)
        Helper.log.info command.yellow.strip if print_command

        if print_all and loading # this is only used to show the "Loading text"...
          clear_display
          puts loading.cyan
        end

        begin
          PTY.spawn(command) do |stdin, stdout, pid|
            stdin.each do |l|
              line = l.strip # strip so that \n gets removed
              output << line

              next unless print_all

              line = line.cyan

              # Prefix the current line with a string
              prefix.each do |element|
                line = element[:prefix] + line if element[:block] && element[:block].call(line)
              end

              # The actual output here, first clear and then print out 3 lines
              clear_display
              puts line
            end
            Process.wait(pid)
            clear_display
          end
        rescue => ex
          # This could happen when the environment is wrong:
          # > invalid byte sequence in US-ASCII (ArgumentError)
          output << ex.to_s
          o = output.join("\n")
          puts o
          error.call(o, nil)
        end

        # Exit status for build command, should be 0 if build succeeded
        status = $?.exitstatus
        if status != 0
          o = output.join("\n")
          puts o # the user has the right to see the raw output
          Helper.log.info "Exit status: #{status}"
          error.call(o, status)
        end

        return output.join("\n")
      end

      def clear_display
        system("clear") unless Helper.ci?
      end
    end
  end
end
