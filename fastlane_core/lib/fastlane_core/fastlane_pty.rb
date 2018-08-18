# Source: Mix of https://github.com/fastlane/fastlane/pull/7202/files,
# https://github.com/fastlane/fastlane/pull/11384#issuecomment-356084518 and
# https://github.com/DragonBox/u3d/blob/59e471ad78ac00cb629f479dbe386c5ad2dc5075/lib/u3d_core/command_runner.rb#L88-L96
module FastlaneCore
  class FastlanePty
    def self.spawn(command, &block)
      require 'pty'
      PTY.spawn(command) do |command_stdout, command_stdin, pid|
        begin
          yield(command_stdout, command_stdin, pid)
        rescue Errno::EIO
          # Exception ignored intentionally.
          # https://stackoverflow.com/questions/10238298/ruby-on-linux-pty-goes-away-without-eof-raises-errnoeio
          # This is expected on some linux systems, that indicates that the subcommand finished
          # and we kept trying to read, ignore it
        ensure
          begin
            Process.wait(pid)
          rescue Errno::ECHILD, PTY::ChildExited
            # The process might have exited.
          end
        end
      end
      $?.exitstatus
    rescue LoadError
      require 'open3'
      Open3.popen2e(command) do |command_stdin, command_stdout, p| # note the inversion
        yield(command_stdout, command_stdin, p.value.pid)

        command_stdin.close
        command_stdout.close
        p.value.exitstatus
      end
    end
  end
end
