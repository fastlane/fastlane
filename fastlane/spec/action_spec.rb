describe Fastlane do
  describe Fastlane::Action do
    describe "#action_name" do
      it "converts the :: format to a readable one" do
        expect(Fastlane::Actions::IpaAction.action_name).to eq('ipa')
        expect(Fastlane::Actions::IncrementBuildNumberAction.action_name).to eq('increment_build_number')
      end
    end

    describe "Call another action from an action" do
      it "allows the user to just call it" do
        Fastlane::Actions.load_external_actions("spec/fixtures/actions")
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileActionFromAction')
        expect(ff.runner.execute(:something, :ios)).to eq("🚀")
      end
    end
  end
end
