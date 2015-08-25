describe Fastlane do
  describe Fastlane::FastFile do
    describe "Snapshot Integration" do
      it "works with default setting" do
        result = Fastlane::FastFile.new.parse("lane :test do
          snapshot
        end").runner.execute(:test)
        expect(result).to eq(true)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SNAPSHOT_SCREENSHOTS_PATH]).to eq(File.expand_path('..', Dir.pwd))
      end

      it "works with :noclean" do
        result = Fastlane::FastFile.new.parse("lane :test do
          snapshot(noclean: true)
        end").runner.execute(:test)
        expect(result).to eq(false)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SNAPSHOT_SCREENSHOTS_PATH]).to eq(File.expand_path('..', Dir.pwd))
      end
    end
  end
end
