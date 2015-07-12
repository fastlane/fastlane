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

    describe "#is_platform_block?" do
      before do
        @ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileGrouped')
      end

      it "return true if it's a platform" do
        expect(@ff.is_platform_block?'mac').to eq(true)
      end

      it "return true if it's a platform" do
        expect(@ff.is_platform_block?'test').to eq(false)
      end

      it "raises an exception if key doesn't exist at all" do
        expect {
          @ff.is_platform_block?"asdf"
        }.to raise_error("Could not find 'asdf'. Available lanes: test, anotherroot, mac beta, ios beta, ios release, android beta, android witherror, android unsupported_action".red)
      end
    end

    describe "#lane_name" do
      before do
        @ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/Fastfile1')
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

    describe "Grouped fastlane for different platforms" do
      before do
        FileUtils.rm_rf('/tmp/fastlane/')

        @ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileGrouped')
      end

      it "calls a block for a given platform (mac - beta)" do
        @ff.runner.execute('beta', 'mac')

        expect(File.exists?('/tmp/fastlane/mac_beta.txt')).to eq(true)
        expect(File.exists?('/tmp/fastlane/before_all_android.txt')).to eq(false)
        expect(File.exists?('/tmp/fastlane/before_all.txt')).to eq(true)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME]).to eq("mac beta")
      end

      it "calls a block for a given platform (android - beta)" do
        @ff.runner.execute('beta', 'android')

        expect(File.exists?('/tmp/fastlane/android_beta.txt')).to eq(true)
        expect(File.exists?('/tmp/fastlane/before_all_android.txt')).to eq(true)
        expect(File.exists?('/tmp/fastlane/after_all_android.txt')).to eq(true)
        expect(File.exists?('/tmp/fastlane/before_all.txt')).to eq(true)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME]).to eq("android beta")
      end

      it "calls all error blocks if multiple are given (android - witherror)" do
        expect {
          @ff.runner.execute('witherror', 'android')
        }.to raise_error 'my exception'

        expect(File.exists?('/tmp/fastlane/before_all_android.txt')).to eq(true)
        expect(File.exists?('/tmp/fastlane/after_all_android.txt')).to eq(false)
        expect(File.exists?('/tmp/fastlane/android_error.txt')).to eq(true)
        expect(File.exists?('/tmp/fastlane/error.txt')).to eq(true)
        expect(File.exists?('/tmp/fastlane/before_all.txt')).to eq(true)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::PLATFORM_NAME]).to eq(:android)
      end

      it "allows calls without a platform (nil - anotherroot)" do
        @ff.runner.execute('anotherroot')

        expect(File.exists?('/tmp/fastlane/before_all_android.txt')).to eq(false)
        expect(File.exists?('/tmp/fastlane/after_all_android.txt')).to eq(false)
        expect(File.exists?('/tmp/fastlane/android_error.txt')).to eq(false)
        expect(File.exists?('/tmp/fastlane/error.txt')).to eq(false)
        expect(File.exists?('/tmp/fastlane/before_all.txt')).to eq(true)
        expect(File.exists?('/tmp/fastlane/another_root.txt')).to eq(true)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME]).to eq("anotherroot")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::PLATFORM_NAME]).to eq(nil)
      end

      it "raises an exception if unsupported action is called in unsupported platform" do
        expect {
          @ff.runner.execute('unsupported_action', 'android')
        }.to raise_error "Action 'frameit' doesn't support required operating system 'android'.".red
      end
    end

    describe "Different Fastfiles" do
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

        expect(ff.runner.description_blocks[nil][:deploy]).to eq("My Deploy\n\ndescription")
        expect(ff.runner.description_blocks[:mac][:specific]).to eq("look at my mac, my mac is amazing")
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
        }.to raise_exception("Could not find lane 'not_here'. Available lanes: test, deploy, error_causing_lane, mac specific".red)
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

  describe "dependencies between lanes" do
    it "collects dependencies from the Fastfile" do
      ff = Fastlane::FastFile.new.parse("
                                     lane :test do
                                     end
                                     depends_on :test
                                     lane :test2 do
                                     end
                                     ")
      expect(ff.runner.configs[nil][:test2].dependencies).to eq([:test])
    end

    it "raises an error if a dependency doesn't exist" do
      expect {
        Fastlane::FastFile.new.parse("
                                     depends_on :test
                                     lane :test2 do
                                     end
                                     ")
      }.to raise_exception "There is no lane called test on platform '' that we could use as dependency for test2".red
    end

    it "raises an error if the dependency is from the wrong platform" do
      expect {
        Fastlane::FastFile.new.parse("
                                     platform :mac do
                                      lane :test do
                                      end
                                     end
                                     platform :ios do
                                      depends_on :test
                                      lane :test2 do
                                      end
                                     end
                                     ")
      }.to raise_exception "There is no lane called test on platform 'ios' that we could use as dependency for test2".red
    end

    it "allows dependencies that don't have a platform" do
      ff = Fastlane::FastFile.new.parse("
                                       lane :test do
                                      end
                                     platform :ios do
                                      depends_on :test
                                      lane :test2 do
                                      end
                                     end
                                       ")
      puts ff.runner.configs
      expect(ff.runner.configs[:ios][:test2].dependencies).to eq([:test])
    end

    it "prevents circular dependencies" do
      expect {
        Fastlane::FastFile.new.parse("
                                     depends_on :test2
                                     lane :test do
                                     end
                                    depends_on :test
                                    lane :test2 do
                                    end
                                     ")
      }.to raise_exception("Circular dependencies detected for lane 'test' with dependency chain: test -> test2 -> test".red)
    end

    it "prevents longer circular dependency chains" do
      expect {
        Fastlane::FastFile.new("./spec/fixtures/fastfiles/FastfileWithDependencyChain")
      }.to raise_exception("Circular dependencies detected for lane 'one' with dependency chain: one -> seven -> six -> three -> two -> one".red)
    end
  end
end
