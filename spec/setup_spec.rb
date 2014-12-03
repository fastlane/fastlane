describe FastLane do
  describe FastLane::Setup do
    describe "Different Fastfiles" do
      it "raises an error if lane is not available" do
        ff = FastLane::FastFile.new('./spec/fixtures/Fastfiles/Fastfile1')
        expect {
          ff.runner.execute(:not_here)
        }.to raise_exception("Could not find lane for type 'not_here'. Available lanes: test, deploy".red)
      end
    end
  end
end
