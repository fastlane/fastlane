describe Fastlane do
  describe Fastlane::Runner do
    describe "#available_lanes" do
      before do
        @ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileGrouped')
      end

      it "lists all available lanes" do
        expect(@ff.runner.available_lanes).to eq(["test", "anotherroot", "mac beta", "ios beta", "ios release", "android beta", "android witherror", "android unsupported_action"])
      end

      it "allows filtering of results" do
        expect(@ff.runner.available_lanes('android')).to eq(["android beta", "android witherror", "android unsupported_action"])
      end

      it "returns an empty array if invalid input is given" do
        expect(@ff.runner.available_lanes('asdfasdfasdf')).to eq([])
      end
    end

    describe "dependencies" do 
      it "runs the dependencies in the defined order" do
        ff = Fastlane::FastFile.new("./spec/fixtures/fastfiles/FastfileWithDependencies")
        expect(ff.runner.execute(:seven)).to eq([1, 2, 3, 4, 5, 6, 7])
      end
    end
  end
end
