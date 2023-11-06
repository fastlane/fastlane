describe FastlaneCore do
  describe FastlaneCore::FastlanePty do
    describe "spawn" do
      it 'executes a simple command successfully' do
        @all_lines = []

        exit_status = FastlaneCore::FastlanePty.spawn('echo foo') do |command_stdout, command_stdin, pid|
          command_stdout.each do |line|
            @all_lines << line
          end
        end
        expect(exit_status).to eq(0)
        expect(@all_lines).to eq(["foo\r\n"])
      end

      it 'doesn t return -1 if an exception was raised in the block' do
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
