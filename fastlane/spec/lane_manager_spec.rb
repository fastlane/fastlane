describe Fastlane do
  describe Fastlane::LaneManager do
    describe "#init" do
      it "raises an error on invalid platform" do
        expect do
          Fastlane::LaneManager.cruise_lane(123, nil)
        end.to raise_error("platform must be a string")
      end
      it "raises an error on invalid lane" do
        expect do
          Fastlane::LaneManager.cruise_lane(nil, 123)
        end.to raise_error("lane must be a string")
      end

      describe "successfull init" do
        before do
          allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
        end

        it "Successfully collected all actions" do
          ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
          expect(ff.collector.launches).to eq({ default_platform: 1, frameit: 1, team_id: 2 })
        end

        it "Successfully handles exceptions" do
          expect do
            ff = Fastlane::LaneManager.cruise_lane('ios', 'crashy')
          end.to raise_error 'my exception'
        end

        it "Uses the default platform if given" do
          ff = Fastlane::LaneManager.cruise_lane(nil, 'empty') # look, without `ios`
          lanes = ff.runner.lanes
          expect(lanes[nil][:test].description).to eq([])
          expect(lanes[:ios][:crashy].description).to eq(["This action does nothing", "but crash"])
          expect(lanes[:ios][:empty].description).to eq([])
        end

        it "supports running a lane without a platform even when there is a default_platform" do
          path = "/tmp/fastlane/tests.txt"
          File.delete(path) if File.exist?(path)
          expect(File.exist?(path)).to eq(false)

          ff = Fastlane::LaneManager.cruise_lane(nil, 'test')

          expect(File.exist?(path)).to eq(true)
          expect(ff.runner.current_lane).to eq(:test)
          expect(ff.runner.current_platform).to eq(nil)
        end
      end
    end
  end
end
