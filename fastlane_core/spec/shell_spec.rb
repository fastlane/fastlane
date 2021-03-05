describe FastlaneCore do
  describe FastlaneCore::Shell do
    describe "command_output" do
      before(:all) do
        @shell = FastlaneCore::Shell.new
      end

      it 'command_output handles encodings incorrectly tagged as UTF-8' do
        expect do
          @shell.command_output("utf_16_string_tagged_as_utf_8\n".encode(Encoding::UTF_16).force_encoding(Encoding::UTF_8))
        end.not_to raise_error
      end
    end
  end
end
