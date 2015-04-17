describe Fastlane do
  describe Fastlane::LaneManager do
    describe "#init", now: true do
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
        end

        it "Successfully collected all actions" do
          ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
          expect(ff.collector.launches).to eq({default_platform:1, frameit: 1, team_id: 2})
        end

        it "Successfully handles exceptions" do
          expect {
            ff = Fastlane::LaneManager.cruise_lane('ios', 'crashy')
          }.to raise_error 'my exception'
        end

        it "Uses the default platform if given" do
          ff = Fastlane::LaneManager.cruise_lane(nil, 'empty') # look, without `ios`
          expect(ff.runner.description_blocks).to eq({nil=>{:test=>"", :anotherroot=>""}, :ios=>{:beta=>"", :empty=>"", :crashy=>""}})
        end
      end
    end
  end
end