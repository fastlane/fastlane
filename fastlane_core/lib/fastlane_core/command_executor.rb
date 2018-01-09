require_relative 'ui/ui'
require_relative 'globals'

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
        # PATHEXT contains the list of file extensions that Windows considers executable, semicolon separated.
        # e.g. ".COM;.EXE;.BAT;.CMD"
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            cmd_path = File.join(path, "#{cmd}#{ext}")
            return cmd_path if File.executable?(cmd_path) && !File.directory?(cmd_path)
          end
        end

        return nil
      end

      # @param command [String] The command to be executed
      # @param print_all [Boolean] Do we want to print out the command output while running?
      # @param print_command [Boolean] Should we print the command that's being executed
      # @param error [Block] A block that's called if an error occurs
      # @param prefix [Array] An array containing a prefix + block which might get applied to the output
      # @param loading [String] A loading string that is shown before the first output
      # @return [String] All the output as string
      def execute(command: nil, print_all: false, print_command: true, error: nil, prefix: nil, loading: nil)
        print_all = true if FastlaneCore::Globals.verbose?
        prefix ||= {}

        output = []
        command = command.join(" ") if command.kind_of?(Array)
        UI.command(command) if print_command

        if print_all and loading # this is only used to show the "Loading text"...
          UI.command_output(loading)
        end

        begin
          require 'pty'
          PTY.spawn(command) do |stdin, stdout, pid|
            begin
              stdin.each do |l|
                line = l.strip # strip so that \n gets removed
                output << line

                next unless print_all

                # Prefix the current line with a string
                prefix.each do |element|
                  line = element[:prefix] + line if element[:block] && element[:block].call(line)
                end

                UI.command_output(line)
              end
            rescue Errno::EIO
              # This is expected on some linux systems, that indicates that the subcommand finished
              # and we kept trying to read, ignore it
            ensure
              Process.wait(pid)
            end
          end
        rescue => ex
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
        status = $?.exitstatus
        if status != 0
          o = output.join("\n")
          puts(o) # the user has the right to see the raw output
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
