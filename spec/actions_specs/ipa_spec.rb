describe Fastlane do
  describe Fastlane::FastFile do
    describe "IPA Integration" do

      it "works with default setting" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          ipa
        end").runner.execute(:test)

        expect(result).to eq([])
      end

      it "works with array of arguments" do

        expect {
          result = Fastlane::FastFile.new.parse("lane :test do 
            ipa '-s TestScheme', '-w Test.xcworkspace'
          end").runner.execute(:test)
        }.to raise_error("`ipa` action parameter must be a hash".red)
      end

      it "works with object argument without clean and archive" do

        result = Fastlane::FastFile.new.parse("lane :test do 
          ipa ({
            workspace: 'Test.xcworkspace',
            project: nil,
            configuration: 'Release',
            scheme: 'TestScheme',
            destination: nil,
            embed: nil,
            identity: nil,
            ipa: 'JoshIsAwesome.ipa'
          })
        end").runner.execute(:test)

        expect(result.size).to eq(4)
      end

      it "works with object argument with clean and archive" do

        result = Fastlane::FastFile.new.parse("lane :test do 
          ipa ({
            workspace: 'Test.xcworkspace',
            project: nil,
            configuration: 'Release',
            scheme: 'TestScheme',
            clean: true,
            archive: nil,
            destination: nil,
            embed: nil,
            identity: nil,
            ipa: 'JoshIsAwesome.ipa'
          })
        end").runner.execute(:test)

        expect(result.size).to eq(6)
      end

      it "works with object argument with all" do

        result = Fastlane::FastFile.new.parse("lane :test do 
          ipa ({
            workspace: 'Test.xcworkspace',
            project: 'Test.xcproject',
            configuration: 'Release',
            scheme: 'TestScheme',
            clean: true,
            archive: nil,
            destination: 'Nowhere',
            embed: 'Sure',
            identity: 'bourne',
            sdk: '10.0',
            ipa: 'JoshIsAwesome.ipa',
            xcconfig: 'SomethingGoesHere',
            xcargs: 'MY_ADHOC_OPT1=0 MY_ADHOC_OPT2=1',
          })
        end").runner.execute(:test)

        expect(result.size).to eq(13)
        expect(result).to include('-w "Test.xcworkspace"')
        expect(result).to include('-p "Test.xcproject"')
        expect(result).to include('-c "Release"')
        expect(result).to include('-s "TestScheme"')
        expect(result).to include('--clean')
        expect(result).to include('--archive')
        expect(result).to include('-d "Nowhere"')
        expect(result).to include('-m "Sure"')
        expect(result).to include('-i "bourne"')
        expect(result).to include('--sdk "10.0"')
        expect(result).to include('--ipa "JoshIsAwesome.ipa"')
        expect(result).to include('--xcconfig "SomethingGoesHere"')
        expect(result).to include('--xcargs "MY_ADHOC_OPT1=0 MY_ADHOC_OPT2=1"')
      end

      it "respects the clean argument when true" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          ipa ({
            clean: true,
          })
        end").runner.execute(:test)

        expect(result).to include("--clean")
      end

      it "respects the clean argument when false" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          ipa ({
            clean: false,
          })
        end").runner.execute(:test)

        expect(result).to include("--no-clean")
      end

      it "works with object argument with all and extras and auto-use sigh profile if not given" do
        ENV["SIGH_PROFILE_PATH"] = "some/great/value.file"

        result = Fastlane::FastFile.new.parse("lane :test do 
          ipa ({
            workspace: 'Test.xcworkspace',
            project: 'Test.xcproject',
            configuration: 'Release',
            scheme: 'TestScheme',
            clean: true,
            archive: nil,
            destination: 'Nowhere',
            identity: 'bourne',
            sdk: '10.0',
            ipa: 'JoshIsAwesome.ipa',
            hehehe: 'hahah'
          })
        end").runner.execute(:test)

        expect(result).to include("-m \"#{ENV['SIGH_PROFILE_PATH']}\"")
        expect(result.size).to eq(11)

        ENV["SIGH_PROFILE_PATH"] = nil
      end

    end
  end
end
