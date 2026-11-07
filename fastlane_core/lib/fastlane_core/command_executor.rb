require 'open3'
require 'shellwords'
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
      # @param suppress_error_output [Boolean] Suppress replaying output and printing the exit status
      #   when the command fails, unless verbose output is enabled.
      # @param env [Hash] environment variables for the command only, never printed: e.g. a value it should not get on its command line
      # @param chdir [String] directory the command runs in; fastlane's own stays as it is
      # @return [String] All the output as string
      def execute(command: nil, print_all: false, print_command: true, error: nil, prefix: nil, loading: nil,
                  suppress_output: false, suppress_error_output: false, env: {}, chdir: nil)
        # Read the output as UTF-8 whatever the user set, as sh does; restored below
        previous_encoding = [Encoding.default_external, Encoding.default_internal]
        Encoding.default_external = Encoding::UTF_8
        Encoding.default_internal = Encoding::UTF_8

        verbose = FastlaneCore::Globals.verbose?
        print_all = true if verbose
        suppress_error_output = false if verbose
        prefix ||= {}

        output = []
        command = command.join(" ") if command.kind_of?(Array)
        UI.command(command) if print_command

        if print_all && loading # this is only used to show the "Loading text"...
          UI.command_output(loading)
        end

        begin
          # Options only when given, so existing calls reach FastlanePty.spawn unchanged
          spawn_options = { env: (env unless env.empty?), chdir: chdir }.compact
          status = FastlaneCore::FastlanePty.spawn(command, **spawn_options) do |command_stdout, command_stdin, pid|
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
          puts(o) unless suppress_error_output
          raise ex unless error
          # Once, with the exit status FastlanePty read: -1 when the command was killed
          error.call(o, ex.exit_status)
          return o
        end

        # Exit status for build command, should be 0 if build succeeded
        if status != 0
          is_output_already_printed = print_all && !suppress_output
          o = output.join("\n")

          unless suppress_error_output
            puts(o) unless is_output_already_printed
            UI.error("Exit status: #{status}")
          end

          if error
            error.call(o, status)
          else
            UI.user_error!("Exit status: #{status}")
          end
        end

        return output.join("\n")
      ensure
        Encoding.default_external = previous_encoding.first
        Encoding.default_internal = previous_encoding.last
      end

      # Runs a program with these arguments, without a shell: nothing needs escaping.
      # An environment Hash may come first, as in Process.spawn.
      # It runs in specs too, unlike Actions.sh, which returns the command string there.
      #
      # @param print_command [Boolean] print the command, shell-escaped
      # @param print_output [Boolean] print stdout and stderr as they come; never forced on, so output that holds a secret stays hidden
      # @param separate_stderr [Boolean] return stdout only; stderr goes to the error
      # @param stdin [String] data written to the program's standard input, which is then closed; fastlane never prints it, the program's own output may
      # @param chdir [String] directory the program runs in; fastlane's own stays as it is
      # @param error [Proc] called with the output (stderr with separate_stderr) and the Process::Status, nil when the
      #   program could not start; its value is returned. Without it, a failure raises.
      # @return [String] the output
      def run(*command, print_command: true, print_output: false, separate_stderr: false, stdin: nil, chdir: nil, error: nil)
        env = command.first.kind_of?(Hash) ? command.shift : {}
        program, *arguments = command
        shell_command = (env.map { |k, v| "#{k}=#{v.to_s.shellescape}" } + [command.shelljoin]).join(" ")
        UI.command(shell_command) if print_command

        # Checked first: starting in a missing directory raises the same Errno::ENOENT as a missing program
        if chdir && !File.directory?(chdir)
          message = "no directory '#{chdir}'"
          return error.call(message, nil) if error
          UI.user_error!("`#{shell_command}` failed: #{message}")
        end

        # [program, program] makes Ruby start the program itself, even with no arguments: a single string would go to a shell
        result = collect(env, [program, program], *arguments, stdin: stdin, separate_stderr: separate_stderr, print_output: print_output, chdir: chdir)
        return result.output if result.status.success?

        failure_output = result.errors || result.output
        return error.call(failure_output, result.status) if error
        UI.user_error!("`#{shell_command}` failed with exit status #{result.status.exitstatus}:\n#{failure_output[-500..] || failure_output}")
      rescue SystemCallError => e
        raise unless e.kind_of?(Errno::ENOENT) || e.kind_of?(Errno::EACCES)
        return error.call(e.message, nil) if error
        UI.user_error!("`#{shell_command}` failed: #{e.message}")
      end

      Result = Struct.new(:output, :errors, :status)

      # Starts the command and collects its output and status; shared by run and Actions.sh.
      # The command takes the forms of Process.spawn: one string goes through a shell, separate arguments do not,
      # and an environment Hash may come first.
      #
      #   collect("ls -la /Applications/Xcode\ 7.3.1.app")
      #   collect("ls", "-la", "/Applications/Xcode 7.3.1.app")
      #   collect({ "FOO" => "Hello" }, "echo $FOO")
      #
      # @param stdin [String] data written to the command's standard input, which is then closed; fastlane never prints it, the command's own output may
      # @param separate_stderr [Boolean] keep stderr apart, in Result#errors
      # @param print_output [Boolean] print stdout and stderr as they come
      # @param chdir [String] directory the command runs in; fastlane's own stays as it is
      # @return [Result] output: everything, or stdout only with separate_stderr; errors: stderr with separate_stderr, else nil
      def collect(*command, stdin: nil, separate_stderr: false, print_output: false, chdir: nil)
        previous_encoding = [Encoding.default_external, Encoding.default_internal]
        Encoding.default_external = Encoding::UTF_8
        Encoding.default_internal = Encoding::UTF_8

        output = +''
        errors = separate_stderr ? +'' : nil
        status = nil
        sanitized_output = false
        print_line = lambda do |line|
          next unless print_output
          # Ensure the string being stripped is in valid UTF-8 format; Otherwise warn at the end
          text = line.encode('UTF-8', invalid: :replace)
          UI.command_output(text.strip)
          sanitized_output = true if text != line
        end

        # chdir only when given, so existing calls reach Open3 unchanged
        Open3.public_send(separate_stderr ? :popen3 : :popen2e, *command, **{ chdir: chdir }.compact) do |command_stdin, io, *error_io, thread|
          # From a thread, so a command that writes a lot before reading its input cannot block on a full pipe
          writer = stdin && Thread.new do
            command_stdin.write(stdin)
          rescue Errno::EPIPE
            # The command exited without reading all of it; its exit status says what happened
          ensure
            command_stdin.close
          end
          # Nothing to give: the command reads end-of-file instead of waiting on an input nobody writes to
          command_stdin.close unless stdin
          # From a thread too, so a command that fills stderr while stdout is read cannot block
          error_reader = errors && Thread.new do
            error_io.first.each do |line|
              print_line.call(line)
              errors << line
            end
          end
          io.sync = true
          io.each do |line|
            print_line.call(line)
            output << line
          end
          error_reader&.join
          status = thread.value
          writer&.join
        end

        UI.important("Command output wasn't valid UTF-8 and was sanitized. Please report the issue.") if sanitized_output
        Result.new(output, errors, status)
      ensure
        Encoding.default_external = previous_encoding.first
        Encoding.default_internal = previous_encoding.last
      end
    end
  end
end
