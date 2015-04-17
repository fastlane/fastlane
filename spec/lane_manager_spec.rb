describe Fastlane do
  describe Fastlane::LaneManager do
    describe "#init" do
      it "raises an error on invalid platform" do
        expect {
          Fastlane::LaneManager.cruise_lane(123, nil)
        }.to raise_error("platform must be a string")
      end
      it "raises an error on invalid lane" do
        expect {
          Fastlane::LaneManager.cruise_lane(nil, 123)
        }.to raise_error("lane must be a string")
      end

      describe "successfull init" do
        before do
          allow(Fastlane::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./spec/fixtures/fastfiles/'))
          @ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
        end

        it "Successfully collected all actions" do
          expect(@ff.collector.launches).to eq({default_platform:1, frameit: 1, team_id: 2})
        end
      end
    end
  end
end