# Source: Mix of https://github.com/fastlane/fastlane/pull/7202/files,
# https://github.com/fastlane/fastlane/pull/11384#issuecomment-356084518 and
# https://github.com/DragonBox/u3d/blob/59e471ad78ac00cb629f479dbe386c5ad2dc5075/lib/u3d_core/command_runner.rb#L88-L96

class StandardError
  def exit_status
    return -1
  end
end

module FastlaneCore
  class FastlanePtyError < StandardError
    attr_reader :exit_status, :process_status
    def initialize(e, exit_status, process_status)
      super(e)
      set_backtrace(e.backtrace) if e
      @exit_status = exit_status
      @process_status = process_status
    end
  end

  class FastlanePty
    def self.spawn(command, &block)
      spawn_with_pty(command, &block)
    rescue LoadError
      spawn_with_popen(command, &block)
    end

    def self.spawn_with_pty(original_command, &block)
      require 'pty'
      # this forces the PTY flush - fixes #21792
      command = ENV['FASTLANE_EXEC_FLUSH_PTY_WORKAROUND'] ? "#{original_command};" : original_command
      # The status is produced in the ensure below and read after the block. It
      # travels in a local rather than in $?, which is a thread global: anything
      # that runs a subprocess in between overwrites it, and nothing writes it at
      # all when the wait does not happen. See fastlane#30188.
      status = nil
      PTY.spawn(command) do |command_stdout, command_stdin, pid|
        begin
          yield(command_stdout, command_stdin, pid)
        rescue Errno::EIO
          # Exception ignored intentionally.
          # https://stackoverflow.com/questions/10238298/ruby-on-linux-pty-goes-away-without-eof-raises-errnoeio
          # This is expected on some linux systems, that indicates that the subcommand finished
          # and we kept trying to read, ignore it
        ensure
          command_stdin.close
          command_stdout.close
          begin
            _pid, status = Process.wait2(pid)
          rescue PTY::ChildExited => e
            # The pty saw the child go before we asked for it. The exception
            # carries the status we were about to wait for.
            status = e.status
          rescue Errno::ECHILD
            # Something else reaped it, so there is nothing left to ask for. $?
            # may still hold it, and may just as easily hold someone else's.
          end
        end
      end
      status ||= self.process_status
      # Better a plain error than a NoMethodError raised from inside the handler
      # that exists to report the failure, which is what nil used to produce.
      raise StandardError, "Could not determine the exit status of the command" if status.nil?
      raise StandardError, "Process crashed" if status.signaled?
      status.exitstatus
    rescue StandardError => e
      # Wrapping any error in FastlanePtyError to allow callers to see and use
      # the exit status that would usually get returned
      status ||= self.process_status
      raise FastlanePtyError.new(e, status&.exitstatus || e.exit_status, status)
    end

    def self.spawn_with_popen(command, &block)
      status = nil
      require 'open3'
      Open3.popen2e(command) do |command_stdin, command_stdout, p| # note the inversion
        status = p.value
        yield(command_stdout, command_stdin, status.pid)
        command_stdin.close
        command_stdout.close
        raise StandardError, "Process crashed" if status.signaled?
        status.exitstatus
      end
    rescue StandardError => e
      # Wrapping any error in FastlanePtyError to allow callers to see and use
      # $?.exitstatus that would usually get returned
      raise FastlanePtyError.new(e, status.exitstatus || e.exit_status, status)
    end

    # to ease mocking
    def self.process_status
      $?
    end
  end
end
