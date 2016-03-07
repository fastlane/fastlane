describe Fastlane do
  describe Fastlane::Action do
    describe "#action_name" do
      it "converts the :: format to a readable one" do
        expect(Fastlane::Actions::IpaAction.action_name).to eq('ipa')
        expect(Fastlane::Actions::IncrementBuildNumberAction.action_name).to eq('increment_build_number')
      end
    end
  end
end
