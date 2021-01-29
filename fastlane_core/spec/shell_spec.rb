describe FastlaneCore do
  describe FastlaneCore::Shell do
    describe "command_output" do
      before(:all) do
        @shell = FastlaneCore::Shell.new
      end

      it 'command_output handles UTF-16 and ISO-8859-1 encoded messages' do
        expect do
          @shell.command_output("string_in_utf-16_with_µ\n".encode('UTF-16'))
          @shell.command_output("string_in_iso-8859-1_with_µ\n".encode('ISO-8859-1'))
        end.not_to raise_error
      end
    end
  end
end
