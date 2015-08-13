module FastlaneCore
  # Executes commands and takes care of error handling and more
  class CommandExecutor
    class << self
      # @param command [String] The command to be executed
      # @param print_all [Boolean] Do we want to print out the command output while running?
      # @param print_command [Boolean] Should we print the command that's being executed
      # @param error [Block] A block that's called if an error occurs
      # @return [String] All the output as string
      def execute(command: nil, print_all: false, print_command: true, error: nil)
        print_all = true if $verbose

        output = []
        command = command.join(" ")
        Helper.log.info command.yellow.strip if print_command

        puts "\n-----".cyan if print_all

        last_length = 0
        begin
          PTY.spawn(command) do |stdin, stdout, pid|
            stdin.each do |l|
              line = l.strip # strip so that \n gets removed
              output << line

              next unless print_all

              current_length = line.length
              spaces = [last_length - current_length, 0].max
              print((line + " " * spaces + "\r").cyan)
              last_length = current_length
            end
            Process.wait(pid)
            puts "-----\n".cyan if print_all
          end
        rescue => ex
          # This could happen when the environment is wrong:
          # > invalid byte sequence in US-ASCII (ArgumentError)
          output << ex.to_s
          o = output.join("\n")
          puts o
          error.call(o)
        end

        # Exit status for build command, should be 0 if build succeeded
        # Disabled Rubocop, since $CHILD_STATUS just is not the same
        status = $?.exitstatus # rubocop:disable Style/SpecialGlobalVars
        if status != 0
          o = output.join("\n")
          puts o # the user has the right to see the raw output
          Helper.log.info "Exit status: #{status}"
          error.call(o)
        end
      end
    end
  end
end
