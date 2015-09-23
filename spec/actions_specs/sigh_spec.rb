describe Fastlane do
  describe Fastlane::FastFile do
    describe "sigh Action" do
      it "properly stores the resulting path in the lane environment" do
        require 'sigh'

        path = "/tmp/something"
        ENV["SIGH_UDID"] = "udid"

        expect(Sigh::Manager).to receive(:start).and_return(path)

        result = Fastlane::FastFile.new.parse("lane :test do
          sigh
        end").runner.execute(:test)

        expect(result).to eq('udid')

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_PROFILE_PATH]).to eq(path)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_PROFILE_PATHS]).to eq([path])
      end
    end
  end
end
