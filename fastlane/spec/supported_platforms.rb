describe Fastlane do
  describe Fastlane::Action do
    describe "#all" do
      it "Contains 3 default supported platforms" do
        expect(Fastlane::SupportedPlatforms.all.count).to eq(3)
      end
    end
    describe "#extra=" do
      after :each do
        Fastlane::SupportedPlatforms.extra = []
      end
      it "allows to add new platforms the list of supported ones" do
        expect(FastlaneCore::UI).to receive(:important).with("Setting '[:abcdef]' as extra SupportedPlatforms")
        Fastlane::SupportedPlatforms.extra = [:abcdef]
        expect(Fastlane::SupportedPlatforms.all).to include(:abcdef)
      end
      it "doesn't break if you pass nil" do
        expect(FastlaneCore::UI).to receive(:important).with("Setting '[]' as extra SupportedPlatforms")
        Fastlane::SupportedPlatforms.extra = nil
        expect(Fastlane::SupportedPlatforms.all.count).to eq(3)
      end
    end
  end
end
