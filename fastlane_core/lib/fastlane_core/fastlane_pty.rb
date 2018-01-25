# Source: Mix of https://github.com/fastlane/fastlane/pull/7202/files,
# https://github.com/fastlane/fastlane/pull/11384#issuecomment-356084518 and
# https://github.com/DragonBox/u3d/blob/59e471ad78ac00cb629f479dbe386c5ad2dc5075/lib/u3d_core/command_runner.rb#L88-L96
module FastlaneCore
  class FastlanePty
    def self.spawn(command, &block)
      require 'pty'
      PTY.spawn(command) do |command_stdout, command_stdin, pid|
        block.call(command_stdout, command_stdin, pid)
      end
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
