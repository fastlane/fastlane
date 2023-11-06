describe FastlaneCore do
  describe FastlaneCore::FastlanePty do
    describe "spawn" do
      it 'executes a simple command successfully' do
        @all_lines = []

        exit_status = FastlaneCore::FastlanePty.spawn('echo foo') do |command_stdout, command_stdin, pid|
          command_stdout.each do |line|
            @all_lines << line.chomp
          end
        end
        expect(exit_status).to eq(0)
        expect(@all_lines).to eq(["foo"])
      end

      it 'doesn t return -1 if an exception was raised in the block in PTY.spawn' do
        @all_lines = []

        exception = StandardError.new
        expect {
          exit_status = FastlaneCore::FastlanePty.spawn('echo foo') do |command_stdout, command_stdin, pid|
            raise exception
          end
        }.to raise_error(FastlaneCore::FastlanePtyError) { |error|
          expect(error.exit_status).to eq(0) # command was success but output handling failed
        }
      end

      it 'doesn t return -1 if an exception was raised in the block in Open3.popen2e' do
        expect(FastlaneCore::FastlanePty).to receive(:require).with("pty").and_raise(LoadError)
        allow(FastlaneCore::FastlanePty).to receive(:require).with("open3").and_call_original
        allow(FastlaneCore::FastlanePty).to receive(:open3)

        @all_lines = []

        exception = StandardError.new
        expect {
          exit_status = FastlaneCore::FastlanePty.spawn('echo foo') do |command_stdout, command_stdin, pid|
            raise exception
          end
        }.to raise_error(FastlaneCore::FastlanePtyError) { |error|
          expect(error.exit_status).to eq(0) # command was success but output handling failed
        }
      end
    end
  end
end
