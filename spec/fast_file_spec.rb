describe FastLane do
  describe FastLane::FastFile do
    describe "#initialize" do
      it "raises an error if file does not exist" do
        expect {
          FastLane::FastFile.new('./spec/fixtures/Fastfiles/FastfileNotHere')
        }.to raise_exception "Could not find Fastfile at path './spec/fixtures/Fastfiles/FastfileNotHere'".red
      end

      it "raises an error if unknow method is called" do
        expect {
          FastLane::FastFile.new('./spec/fixtures/Fastfiles/FastfileInvalid')
        }.to raise_exception "Could not find method 'laneasdf'. Use `lane :name do ... end`".red
      end
    end

    describe "Different Fastfiles" do
      it "execute different envs" do
        FileUtils.rm_rf('/tmp/fastlane/')
        FileUtils.mkdir_p('/tmp/fastlane/')

        ff = FastLane::FastFile.new('./spec/fixtures/Fastfiles/Fastfile1')
        ff.runner.execute(:deploy)
        expect(File.exists?('/tmp/fastlane/before_all')).to eq(true)
        expect(File.exists?('/tmp/fastlane/deploy')).to eq(true)
        expect(File.exists?('/tmp/fastlane/test')).to eq(false)
        expect(File.exists?('/tmp/fastlane/after_all')).to eq(true)

        ff.runner.execute(:test)
        expect(File.exists?('/tmp/fastlane/test')).to eq(true)
      end

      it "raises an error if lane is not available" do
        ff = FastLane::FastFile.new('./spec/fixtures/Fastfiles/Fastfile1')
        expect {
          ff.runner.execute(:not_here)
        }.to raise_exception("Could not find lane for type 'not_here'. Available lanes: test, deploy".red)
      end
    end
  end
end
