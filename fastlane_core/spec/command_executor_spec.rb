describe FastlaneCore do
  describe FastlaneCore::CommandExecutor do
    describe "execute" do
      let(:failing_command) { FastlaneCore::Helper.windows? ? 'echo log && exit 42' : 'echo log; exit 42' }
      let(:failing_command_output) { FastlaneCore::Helper.windows? ? "log \n" : "log\n" }
      let(:failing_command_error_input) { FastlaneCore::Helper.windows? ? "log " : "log" }

      it 'executes a simple command successfully' do
        unless FastlaneCore::Helper.windows?
          expect(Process).to receive(:wait)
        end

        result = FastlaneSpec::Env.with_env_values('FASTLANE_EXEC_FLUSH_PTY_WORKAROUND' => '1') do
          FastlaneCore::CommandExecutor.execute(command: 'echo foo')
        end

        expect(result).to eq('foo')
      end

      it 'handles reading which throws a EIO exception', requires_pty: true do
        fake_std_in_lines = [
          "a_filename\n"
        ]
        fake_std_in = double("stdin")
        expect(fake_std_in).to receive(:each).and_yield(*fake_std_in_lines).and_raise(Errno::EIO)

        fake_std_out = double("stdout")

        expect(fake_std_in).to receive(:close)
        expect(fake_std_out).to receive(:close)

        # Make a fake child process so we have a valid PID and $? is set correctly
        expect(PTY).to receive(:spawn) do |command, &block|
          expect(command).to eq('ls')

          # PTY uses "$?" to get exitcode, which is filled in by Process.wait(),
          # so we have to spawn a real process unless we want to mock methods
          # on nil.
          child_process_id = Process.spawn('echo foo', out: File::NULL)
          expect(Process).to receive(:wait).with(child_process_id)

          block.yield(fake_std_in, fake_std_out, child_process_id)
        end

        result = FastlaneCore::CommandExecutor.execute(command: 'ls')

        # We are implicitly also checking that the error was not rethrown because that would
        # have crashed the test
        expect(result).to eq('a_filename')
      end

      it 'chomps but does not strip output lines', requires_pty: true do
        fake_std_in = [
          "Shopping list:\n",
          "  - Milk\n",
          "\r  - Bread\n",
          "  - Muffins\n"
        ]

        fake_std_out = 'not_really_std_out'

        expect(fake_std_in).to receive(:close)
        expect(fake_std_out).to receive(:close)

        expect(PTY).to receive(:spawn) do |command, &block|
          expect(command).to eq('echo foo')

          # PTY uses "$?" to get exitcode, which is filled in by Process.wait(),
          # so we have to spawn a real process unless we want to mock methods
          # on nil.
          child_process_id = Process.spawn('echo foo', out: File::NULL)
          expect(Process).to receive(:wait).with(child_process_id)

          block.yield(fake_std_in, fake_std_out, child_process_id)
        end

        result = FastlaneCore::CommandExecutor.execute(command: 'echo foo')

        # We are implicitly also checking that the error was not rethrown because that would
        # have crashed the test
        expect(result).to eq(<<-LIST.chomp)
Shopping list:
  - Milk
  - Bread
  - Muffins
        LIST
      end

      it "does not print output to stdout when status != 0 and output was already printed" do
        unless FastlaneCore::Helper.windows?
          expect(Process).to receive(:wait)
        end

        expect do
          FastlaneCore::CommandExecutor.execute(
            command: failing_command,
            print_all: true,
            error: proc do |_error_output| end
          )
        end.not_to output(failing_command_output).to_stdout
      end

      it "prints output to stdout only once when status != 0 and output was not already printed" do
        unless FastlaneCore::Helper.windows?
          expect(Process).to receive(:wait).exactly(3)
        end

        expect do
          FastlaneCore::CommandExecutor.execute(
            command: failing_command,
            print_all: false,
            error: nil
          )
        end.to output(failing_command_output).to_stdout.and(raise_error(FastlaneCore::Interface::FastlaneError) do |error|
          expect(error.to_s).to eq("Exit status: 42")
        end)

        expect do
          FastlaneCore::CommandExecutor.execute(
            command: failing_command,
            print_all: false,
            error: proc do |_error_output| end
          )
        end.to output(failing_command_output).to_stdout

        expect do
          FastlaneCore::CommandExecutor.execute(
            command: failing_command,
            print_all: true,
            suppress_output: true,
            error: proc do |_error_output| end
          )
        end.to output(failing_command_output).to_stdout
      end

      it "calls error block with output argument" do
        unless FastlaneCore::Helper.windows?
          expect(Process).to receive(:wait).twice
        end

        error_block_input = nil
        result = FastlaneCore::CommandExecutor.execute(
          command: failing_command,
          print_all: true,
          error: proc do |error_output|
            error_block_input = error_output
          end
        )
        expect(error_block_input).to eq(failing_command_error_input)

        error_block_input = nil
        result = FastlaneCore::CommandExecutor.execute(
          command: failing_command,
          print_all: false,
          error: proc do |error_output|
            error_block_input = error_output
          end
        )
        expect(error_block_input).to eq(failing_command_error_input)
      end

      it "does not print output or exit status when failure output is suppressed" do
        unless FastlaneCore::Helper.windows?
          expect(Process).to receive(:wait)
        end

        error_block_input = nil
        error_block_status = nil

        expect(FastlaneCore::UI).not_to receive(:error)

        expect do
          FastlaneCore::CommandExecutor.execute(
            command: failing_command,
            print_all: false,
            print_command: false,
            suppress_error_output: true,
            error: proc do |error_output, status|
              error_block_input = error_output
              error_block_status = status
            end
          )
        end.not_to output.to_stdout

        expect(error_block_input).to eq(failing_command_error_input)
        expect(error_block_status).to eq(42)
      end

      it "prints output and exit status when failure output is suppressed in verbose mode" do
        expect(FastlaneCore::FastlanePty).to receive(:spawn) do |command, &block|
          expect(command).to eq("failing command")

          block.yield(["log\n"], nil, nil)
          42
        end

        error_block_input = nil
        error_block_status = nil

        expect(FastlaneCore::UI).to receive(:command_output).with("log")
        expect(FastlaneCore::UI).to receive(:error).with("Exit status: 42")

        FastlaneSpec::Env.with_verbose(true) do
          FastlaneCore::CommandExecutor.execute(
            command: "failing command",
            print_command: false,
            suppress_error_output: true,
            error: proc do |error_output, status|
              error_block_input = error_output
              error_block_status = status
            end
          )
        end

        expect(error_block_input).to eq("log")
        expect(error_block_status).to eq(42)
      end

      it "does not print rescued command output when failure output is suppressed" do
        command_error = StandardError.new("pty error")
        allow(command_error).to receive(:exit_status).and_return(42)
        expect(FastlaneCore::FastlanePty).to receive(:spawn).and_raise(command_error)

        error_block_input = nil

        expect do
          FastlaneCore::CommandExecutor.execute(
            command: "failing command",
            print_command: false,
            suppress_error_output: true,
            error: proc do |error_output|
              error_block_input = error_output
            end
          )
        end.not_to output.to_stdout

        expect(error_block_input).to eq("pty error")
      end

      it "prints rescued command output when failure output is suppressed in verbose mode" do
        command_error = StandardError.new("pty error")
        allow(command_error).to receive(:exit_status).and_return(42)
        expect(FastlaneCore::FastlanePty).to receive(:spawn).and_raise(command_error)

        error_block_input = nil
        error_block_status = nil

        expect(FastlaneCore::UI).to receive(:error).with("Exit status: 42")

        expect do
          FastlaneSpec::Env.with_verbose(true) do
            FastlaneCore::CommandExecutor.execute(
              command: "failing command",
              print_command: false,
              suppress_error_output: true,
              error: proc do |error_output, status|
                error_block_input = error_output
                error_block_status = status
              end
            )
          end
        end.to output("pty error\n").to_stdout

        expect(error_block_input).to eq("pty error")
        expect(error_block_status).to eq(42)
      end

      it "still raises when failure output is suppressed without an error block" do
        unless FastlaneCore::Helper.windows?
          expect(Process).to receive(:wait)
        end

        raised_error = nil

        expect(FastlaneCore::UI).not_to receive(:error)

        expect do
          begin
            FastlaneCore::CommandExecutor.execute(
              command: failing_command,
              print_all: false,
              print_command: false,
              suppress_error_output: true
            )
          rescue => ex
            raised_error = ex
          end
        end.not_to output.to_stdout

        expect(raised_error).to be_a(FastlaneCore::Interface::FastlaneError)
        expect(raised_error.to_s).to eq("Exit status: 42")
      end
    end

    describe "which" do
      require 'tempfile'

      it "does not find commands which are not on the PATH" do
        expect(FastlaneCore::CommandExecutor.which('not_a_real_command')).to be_nil
      end

      it "finds commands without extensions which are on the PATH" do
        allow(FastlaneCore::Helper).to receive(:windows?).and_return(false)

        Tempfile.open('foobarbaz') do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f)

          FastlaneSpec::Env.with_env_values('PATH' => temp_dir) do
            expect(FastlaneCore::CommandExecutor.which(temp_cmd)).to eq(f.path)
          end
        end
      end

      it "finds commands without extensions which are on the PATH on Windows", if: FastlaneCore::Helper.windows? do
        Tempfile.open('foobarbaz') do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f)

          FastlaneSpec::Env.with_env_values('PATH' => temp_dir) do
            expect(FastlaneCore::CommandExecutor.which(temp_cmd)).to eq(f.path.gsub('/', '\\'))
          end
        end
      end

      it "finds commands with known extensions which are on the PATH", if: FastlaneCore::Helper.windows? do
        allow(FastlaneCore::Helper).to receive(:windows?).and_return(true)

        Tempfile.open(['foobarbaz', '.exe']) do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f, '.exe')

          FastlaneCore::CommandExecutor.which(temp_cmd)

          FastlaneSpec::Env.with_env_values('PATH' => temp_dir, 'PATHEXT' => '.exe') do
            expect(FastlaneCore::CommandExecutor.which(temp_cmd)).to eq(f.path.gsub('/', '\\'))
          end
        end
      end

      it "does not find commands with unknown extensions which are on the PATH" do
        allow(FastlaneCore::Helper).to receive(:windows?).and_return(true)

        Tempfile.open(['foobarbaz', '.exe']) do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f, '.exe')

          FastlaneSpec::Env.with_env_values('PATH' => temp_dir, 'PATHEXT' => '') do
            expect(FastlaneCore::CommandExecutor.which(temp_cmd)).to be_nil
          end
        end
      end
    end
  end
end
