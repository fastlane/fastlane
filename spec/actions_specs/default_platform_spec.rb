describe Fastlane do
  describe Fastlane::FastFile do
    describe "Default Platform Action" do
      it "stores the default platform and converts to a symbol" do
        Fastlane::Actions::DefaultPlatformAction.run(['ios'])
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DEFAULT_PLATFORM]).to eq(:ios)
      end

      it "raises an error if platform is not supported" do
        expect do
          Fastlane::Actions::DefaultPlatformAction.run(['notSupportedOS'])
        end.to raise_error("Platform 'notSupportedOS' is not supported. Must be either [:ios, :mac, :android]".red)
      end

      it "raises an error if no platform is given" do
        expect do
          Fastlane::Actions::DefaultPlatformAction.run([])
        end.to raise_error("You forgot to pass the default platform".red)
      end

      it "works as expected inside a Fastfile" do
        Fastlane::FastFile.new.parse("lane :test do
          default_platform :ios
        end").runner.execute(:test)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DEFAULT_PLATFORM]).to eq(:ios)
      end
    end
  end
end
