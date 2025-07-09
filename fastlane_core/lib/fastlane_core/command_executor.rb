require_relative 'ui/ui'
require_relative 'globals'
require_relative 'fastlane_pty'

module FastlaneCore
  # Executes commands and takes care of error handling and more
  class CommandExecutor
    class << self
      # Cross-platform way of finding an executable in the $PATH. Respects the $PATHEXT, which lists
      # valid file extensions for executables on Windows.
      #
      #    which('ruby') #=> /usr/bin/ruby
      #
      # Derived from https://stackoverflow.com/a/5471032/3005
      def which(cmd)
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          cmd_path = File.join(path, cmd)
          executable_path = Helper.get_executable_path(cmd_path)
          return executable_path if Helper.executable?(executable_path)
        end

        return nil
      end

      # @param command [String] The command to be executed
      # @param print_all [Boolean] Do we want to print out the command output while running?
      # @param print_command [Boolean] Should we print the command that's being executed
      # @param error [Block] A block that's called if an error occurs
      # @param prefix [Array] An array containing a prefix + block which might get applied to the output
      # @param loading [String] A loading string that is shown before the first output
      # @param suppress_output [Boolean] Should we print the command's output?
      # @return [String] All the output as string
      def execute(command: nil, print_all: false, print_command: true, error: nil, prefix: nil, loading: nil, suppress_output: false)
        print_all = true if FastlaneCore::Globals.verbose?
        prefix ||= {}

        output = []
        command = command.join(" ") if command.kind_of?(Array)
        UI.command(command) if print_command

        if print_all && loading # this is only used to show the "Loading text"...
          UI.command_output(loading)
        end

        begin
          status = FastlaneCore::FastlanePty.spawn(command) do |command_stdout, command_stdin, pid|
            command_stdout.each do |l|
              line = l.chomp
              line = line[1..-1] if line[0] == "\r"
              output << line

              next unless print_all

              # Prefix the current line with a string
              prefix.each do |element|
                line = element[:prefix] + line if element[:block] && element[:block].call(line)
              end

              UI.command_output(line) unless suppress_output
            end
          end
        rescue => ex
          # FastlanePty adds exit_status on to StandardError so every error will have a status code
          status = ex.exit_status

          # This could happen when the environment is wrong:
          # > invalid byte sequence in US-ASCII (ArgumentError)
          output << ex.to_s
          o = output.join("\n")
          puts(o)
          if error
            error.call(o, nil)
          else
            raise ex
          end
        end

        # Exit status for build command, should be 0 if build succeeded
        if status != 0
          is_output_already_printed = print_all && !suppress_output
          o = output.join("\n")
          puts(o) unless is_output_already_printed

          UI.error("Exit status: #{status}")
          if error
            error.call(o, status)
          else
            UI.user_error!("Exit status: #{status}")
          end
        end

        return output.join("\n")
      end
    end
  end
end
