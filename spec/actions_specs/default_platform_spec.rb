describe Fastlane do
  describe Fastlane::FastFile do
    describe "Default Platform Action", now: true do
      it "stores the default platform" do
        Fastlane::Actions::DefaultPlatformAction.run(['ios'])
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DEFAULT_PLATFORM]).to eq('ios')
      end
    end
  end
end
