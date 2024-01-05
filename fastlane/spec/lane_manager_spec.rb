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

      describe "successful init" do
        before do
          allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
        end

        it "Successfully handles exceptions" do
          expect do
            ff = Fastlane::LaneManager.cruise_lane('ios', 'crashy')
          end.to raise_error('my exception')
        end

        it "Uses the default platform if given" do
          ff = Fastlane::LaneManager.cruise_lane(nil, 'empty') # look, without `ios`
          lanes = ff.runner.lanes
          expect(lanes[nil][:test].description).to eq([])
          expect(lanes[:ios][:crashy].description).to eq(["This action does nothing", "but crash"])
          expect(lanes[:ios][:empty].description).to eq([])
        end

        it "Supports running a lane without a platform even when there is a default_platform" do
          path = "/tmp/fastlane/tests.txt"
          File.delete(path) if File.exist?(path)
          expect(File.exist?(path)).to eq(false)

          ff = Fastlane::LaneManager.cruise_lane(nil, 'test')

          expect(File.exist?(path)).to eq(true)
          expect(ff.runner.current_lane).to eq(:test)
          expect(ff.runner.current_platform).to eq(nil)
        end

        it "Supports running a lane with custom Fastfile path" do
          path = "./fastlane/spec/fixtures/fastfiles/FastfileCruiseLane"

          ff = Fastlane::LaneManager.cruise_lane(nil, 'test', nil, path)
          lanes = ff.runner.lanes
          expect(lanes[nil][:test].description).to eq(["test description for cruise lanes"])
          expect(lanes[:ios][:apple].description).to eq([])
          expect(lanes[:android][:robot].description).to eq([])
        end

        it "Does output a summary table when FASTLANE_SKIP_ACTION_SUMMARY ENV variable is not set" do
          ENV["FASTLANE_SKIP_ACTION_SUMMARY"] = nil
          expect(Terminal::Table).to(receive(:new).with(title: "fastlane summary".green, headings: anything, rows: anything))
          ff = Fastlane::LaneManager.cruise_lane(nil, 'test')
        end

        it "Does not output summary table when FASTLANE_SKIP_ACTION_SUMMARY ENV variable is set" do
          ENV["FASTLANE_SKIP_ACTION_SUMMARY"] = "true"
          expect(Terminal::Table).to_not(receive(:new).with(title: "fastlane summary".green, headings: anything, rows: anything))
          ff = Fastlane::LaneManager.cruise_lane(nil, 'test')
          ENV["FASTLANE_SKIP_ACTION_SUMMARY"] = nil
        end
      end
    end
  end
end
