describe Fastlane do
  describe Fastlane::FastFile do
    describe "Default Platform Action" do
      it "stores the default platform and converts to a symbol" do
        Fastlane::Actions::DefaultPlatformAction.run(['ios'])
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DEFAULT_PLATFORM]).to eq(:ios)
      end

      it "raises an error if platform is not supported" do
        expect {
          Fastlane::Actions::DefaultPlatformAction.run(['notSupportedOS'])
        }.to raise_error("Platform 'notSupportedOS' is not supported. Must be either [:ios, :mac, :android]".red)
      end

      it "raises an error if no platform is given" do
        expect {
          Fastlane::Actions::DefaultPlatformAction.run([])
        }.to raise_error("You forgot to pass the default platform".red)
      end
    end
  end
end
