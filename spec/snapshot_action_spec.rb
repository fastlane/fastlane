describe Fastlane do
  describe Fastlane::FastFile do
    describe "Snapshot Integration" do

      it "works with default setting" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          snapshot
        end").runner.execute(:test)
        expect(result.first).to eq("snapshot")

        expect(ENV['SNAPSHOT_SCREENSHOTS_PATH']).to eq("./screenshots")
      end

    end
  end
end
