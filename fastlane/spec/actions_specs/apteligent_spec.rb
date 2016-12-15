describe Fastlane do
  describe Fastlane::FastFile do
    describe "apteligent" do
      it "raises an error if no dsym source has been found" do
        expect do
          ENV['DSYM_OUTPUT_PATH'] = nil
          ENV['DSYM_ZIP_PATH'] = nil
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

          Fastlane::Actions::ApteligentAction.dsym_path(params: nil)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end

      it "mandatory options are used correctly" do
        ENV['DSYM_OUTPUT_PATH'] = nil
        ENV['DSYM_ZIP_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        dsym_path = File.expand_path('./fastlane/spec/fixtures/dSYM/Themoji.dSYM.zip')
        result = Fastlane::FastFile.new.parse("lane :test do
          apteligent(dsym: '#{dsym_path}',app_id: '123',api_key: 'abc')
        end").runner.execute(:test)

        expect(result).to include("https://api.crittercism.com/api_beta/dsym/123")
        expect(result).to include("-F dsym=@#{Shellwords.shellescape(dsym_path)}")
        expect(result).to include("-F key=abc")
      end
    end
  end
end
