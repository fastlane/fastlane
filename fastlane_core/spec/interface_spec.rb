describe FastlaneCore::Interface do
  describe "Abort helper methods" do
    describe "#abort_with_message!" do
      it "raises FastlaneCommonException" do
        expect do
          FastlaneCore::Interface.new.abort_with_message!("Yup")
        end.to raise_error(FastlaneCore::Interface::FastlaneCommonException, "Yup")
      end
    end
  end
end
