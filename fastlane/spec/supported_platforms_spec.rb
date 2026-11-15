describe Fastlane do
  describe Fastlane::Action do
    describe "#all" do
      it "Contains 3 default supported platforms" do
        expect(Fastlane::SupportedPlatforms.all.count).to eq(3)
      end
    end
    describe "#extra=" do
      before :each do
        allow(FastlaneCore::UI).to receive(:important)
      end
      after :each do
        Fastlane::SupportedPlatforms.extra = []
      end
      it "allows to add new platforms the list of supported ones" do
        Fastlane::SupportedPlatforms.extra = [:abcdef]
        expect(FastlaneCore::UI).to have_received(:important).with("Setting '[:abcdef]' as extra SupportedPlatforms")
        expect(Fastlane::SupportedPlatforms.all).to include(:abcdef)
      end
      it "doesn't break if you pass nil" do
        Fastlane::SupportedPlatforms.extra = nil
        expect(FastlaneCore::UI).to have_received(:important).with("Setting '[]' as extra SupportedPlatforms")
        expect(Fastlane::SupportedPlatforms.all.count).to eq(3)
      end
    end
  end
end
