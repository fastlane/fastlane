describe Fastlane do
  describe Fastlane::FastFile do
    describe "Default Platform Action" do
      it "stores the default platform and converts to a symbol" do
        Fastlane::Actions::DefaultPlatformAction.run(['ios'])
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DEFAULT_PLATFORM]).to eq(:ios)
      end

      it "raises an error if no platform is given" do
        expect do
          Fastlane::Actions::DefaultPlatformAction.run([])
        end.to raise_error("You forgot to pass the default platform")
      end

      it "works as expected inside a Fastfile" do
        Fastlane::FastFile.new.parse("lane :test do
          default_platform :ios
        end").runner.execute(:test)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DEFAULT_PLATFORM]).to eq(:ios)
      end
    end
    describe "Extra platforms" do
      around(:each) do |example|
        Fastlane::SupportedPlatforms.extra = []
        example.run
        Fastlane::SupportedPlatforms.extra = []
      end
      it "displays a warning if a platform is not supported" do
        expect(FastlaneCore::UI).to receive(:important).with("Platform 'notSupportedOS' is not officially supported. Currently supported platforms are [:ios, :mac, :android].")
        Fastlane::Actions::DefaultPlatformAction.run(['notSupportedOS'])
      end

      it "doesn't display a warning at every run if a platform has been added to extra" do
        Fastlane::SupportedPlatforms.extra = [:notSupportedOS]
        expect(FastlaneCore::UI).not_to(receive(:important))
        Fastlane::Actions::DefaultPlatformAction.run(['notSupportedOS'])
      end
    end
  end
end
