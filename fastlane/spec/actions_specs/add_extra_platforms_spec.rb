describe Fastlane do
  describe Fastlane::FastFile do
    describe "add_extra_platforms" do
      before(:each) do
        allow(Fastlane::SupportedPlatforms).to receive(:all).and_return([:ios, :macos, :android])
      end

      it "updates the extra supported platforms" do
        expect(UI).to receive(:verbose).with("Before injecting extra platforms: [:ios, :macos, :android]")
        expect(Fastlane::SupportedPlatforms).to receive(:extra=).with([:windows, :neogeo])
        expect(UI).to receive(:verbose).with("After injecting extra platforms ([:windows, :neogeo])...: [:ios, :macos, :android]")

        Fastlane::FastFile.new.parse("lane :test do
          add_extra_platforms(platforms: [:windows, :neogeo])
        end").runner.execute(:test)
      end
    end
  end
end
