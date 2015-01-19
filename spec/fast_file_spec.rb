describe Fastlane do
  describe Fastlane::FastFile do
    describe "#initialize" do
      it "raises an error if file does not exist" do
        expect {
          Fastlane::FastFile.new('./spec/fixtures/Fastfiles/FastfileNotHere')
        }.to raise_exception "Could not find Fastfile at path './spec/fixtures/Fastfiles/FastfileNotHere'".red
      end

      it "raises an error if unknow method is called" do
        expect {
          Fastlane::FastFile.new('./spec/fixtures/Fastfiles/FastfileInvalid')
        }.to raise_exception "Could not find method 'laneasdf'. Check out the README for more details: https://github.com/KrauseFx/fastlane".red
      end
    end

    describe "Different Fastfiles" do
      it "execute different envs" do
        FileUtils.rm_rf('/tmp/fastlane/')
        FileUtils.mkdir_p('/tmp/fastlane/')

        ff = Fastlane::FastFile.new('./spec/fixtures/Fastfiles/Fastfile1')
        ff.runner.execute(:deploy)
        expect(File.exists?('/tmp/fastlane/before_all')).to eq(true)
        expect(File.exists?('/tmp/fastlane/deploy')).to eq(true)
        expect(File.exists?('/tmp/fastlane/test')).to eq(false)
        expect(File.exists?('/tmp/fastlane/after_all')).to eq(true)
        expect(File.read("/tmp/fastlane/after_all")).to eq("deploy")

        ff.runner.execute(:test)
        expect(File.exists?('/tmp/fastlane/test')).to eq(true)
      end

      it "raises an error if lane is not available" do
        ff = Fastlane::FastFile.new('./spec/fixtures/Fastfiles/Fastfile1')
        expect {
          ff.runner.execute(:not_here)
        }.to raise_exception("Could not find lane for type 'not_here'. Available lanes: test, deploy, error_causing_lane".red)
      end

      it "runs pod install" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          cocoapods
        end").runner.execute(:test)

        expect(result).to eq("pod install")
      end

      it "calls the error block when an error occurs" do
        FileUtils.rm_rf('/tmp/fastlane/')
        FileUtils.mkdir_p('/tmp/fastlane/')

        ff = Fastlane::FastFile.new('./spec/fixtures/Fastfiles/Fastfile1')
        expect {
          ff.runner.execute(:error_causing_lane)
        }.to raise_exception("divided by 0")

        expect(File.exists?('/tmp/fastlane/before_all')).to eq(true)
        expect(File.exists?('/tmp/fastlane/deploy')).to eq(false)
        expect(File.exists?('/tmp/fastlane/test')).to eq(false)
        expect(File.exists?('/tmp/fastlane/after_all')).to eq(false)
        expect(File.exists?('/tmp/fastlane/error')).to eq(true)
        
        expect(File.read("/tmp/fastlane/error")).to eq("error_causing_lane")
      end

      it "raises an error if one lane is defined multiple times" do 
        expect {
          Fastlane::FastFile.new.parse("lane :test do 
          end
          lane :test do
          end")
        }.to raise_exception "Lane 'test' was defined multiple times!".red
      end
    end
  end
end
