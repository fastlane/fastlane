describe FastlaneCore do
  describe FastlaneCore::Shell do
    describe "command_output" do
      before(:all) do
        @shell = FastlaneCore::Shell.new
      end

      it 'command_output handles encodings incorrectly tagged as UTF-8' do
        expect do
          @shell.command_output("utf_16_string_tagged_as_utf_8\n".encode(Encoding::UTF_16).force_encoding(Encoding::UTF_8))
          @shell.command_output("µm\n".encode(Encoding::UTF_16).force_encoding(Encoding::UTF_8))
        end.not_to raise_error
      end
    end

    describe "a prompt when not interactive" do
      it "is a user error, not a crash" do
        shell = FastlaneCore::Shell.new
        allow(shell).to receive(:interactive?).and_return(false)
        allow(shell).to receive(:important)
        expect(shell).not_to receive(:ask)
        expect { shell.input("Scheme?") }.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not retrieve response as fastlane runs in non-interactive mode")
      end
    end
  end
end
