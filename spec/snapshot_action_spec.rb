describe Fastlane do
  describe Fastlane::FastFile do
    describe "Snapshot Integration" do

      it "works with default setting" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          snapshot
        end").runner.execute(:test)
        expect(result.first).to eq("snapshot")
      end

    end
  end
end
