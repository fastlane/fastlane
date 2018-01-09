describe Fastlane do
  describe Fastlane::FastFile do
    describe "TestFairy Integration" do
      it "raises an error if no parameters were given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            testfairy()
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end

      it "raises an error if no api key was given" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            testfairy({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            })
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /No API key/)
      end

      it "raises an error if no ipa path was given" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            testfairy({
              api_key: 'thisistest',
            })
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Couldn't find ipa file at path ''/)
      end

      it "raises an error if the given ipa path was not found" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            testfairy({
              api_key: 'thisistest',
              ipa_path: './fastlane/nonexistent'
            })
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Could not find option 'ipa_path'/)
      end

      it "works with valid required parameters" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            testfairy({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              api_key: 'thisistest',
            })
          end").runner.execute(:test)
        end.not_to(raise_error)
      end

      it "works with valid optional parameters" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            testfairy({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              api_key: 'thisistest',
              comment: 'Test Comment!',
              testers_groups: ['group1', 'group2']
            })
          end").runner.execute(:test)
        end.not_to(raise_error)
      end
    end
  end
end
