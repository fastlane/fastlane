describe Fastlane do
  describe Fastlane::FastFile do
    describe "#initialize" do
      it "raises an error if file does not exist" do
        expect {
          Fastlane::FastFile.new('./spec/fixtures/fastfiles/fastfileNotHere')
        }.to raise_exception "Could not find Fastfile at path './spec/fixtures/fastfiles/fastfileNotHere'".red
      end

      it "raises an error if unknow method is called" do
        expect {
          Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileInvalid')
        }.to raise_exception "Could not find method 'laneasdf'. Check out the README for more details: https://github.com/KrauseFx/fastlane".red
      end
    end

    describe "#lane_name" do
      before do
        @ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/Fastfile1')
      end

      it "raises an error if name is missing" do
        expect { @ff.lane }.to raise_exception "You have to pass a valid name for this lane".red
      end

      it "raises an error if block is missing" do
        expect { 
          @ff.lane("my_name") 
        }.to raise_exception "You have to pass a block using 'do' for lane 'my_name'. Make sure you read the docs on GitHub.".red
      end

      it "takes the block and lane name" do
        @ff.lane "my_name" do

        end
      end
    end

    describe "Different Fastfiles" do
      it "rejects unsupported operating systems" do
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileUnsupportedOS')
        expect {
          ff.runner.execute(:test)
        }.to raise_exception("Action 'frameit' doesn't support required operating system 'android', 'dosphone'.".red)
      end

      it "works with valid operating systems" do
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileSupportedOS')
        ff.runner.execute(:test)
      end

      it "execute different envs" do
        FileUtils.rm_rf('/tmp/fastlane/')
        FileUtils.mkdir_p('/tmp/fastlane/')

        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/Fastfile1')
        ff.runner.execute(:deploy)
        expect(File.exists?('/tmp/fastlane/before_all')).to eq(true)
        expect(File.exists?('/tmp/fastlane/deploy')).to eq(true)
        expect(File.exists?('/tmp/fastlane/test')).to eq(false)
        expect(File.exists?('/tmp/fastlane/after_all')).to eq(true)
        expect(File.read("/tmp/fastlane/after_all")).to eq("deploy")

        ff.runner.execute(:test)
        expect(File.exists?('/tmp/fastlane/test')).to eq(true)
      end

      it "collects the lane description for documentation" do
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/Fastfile1')
        ff.runner.execute(:deploy)
        expect(ff.runner.description_blocks[:deploy]).to eq("My Deploy\n\ndescription")
      end

      it "execute different envs with lane in before block" do
        FileUtils.rm_rf('/tmp/fastlane/')
        FileUtils.mkdir_p('/tmp/fastlane/')

        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/Fastfile2')
        ff.runner.execute(:deploy)
        expect(File.exists?('/tmp/fastlane/before_all_deploy')).to eq(true)
        expect(File.exists?('/tmp/fastlane/deploy')).to eq(true)
        expect(File.exists?('/tmp/fastlane/test')).to eq(false)
        expect(File.exists?('/tmp/fastlane/after_all')).to eq(true)
        expect(File.read("/tmp/fastlane/after_all")).to eq("deploy")

        ff.runner.execute(:test)
        expect(File.exists?('/tmp/fastlane/test')).to eq(true)
      end

      it "raises an error if lane is not available" do
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/Fastfile1')
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

        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/Fastfile1')
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
