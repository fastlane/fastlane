describe Fastlane do
  describe Fastlane::FastFile do
    describe "apteligent" do
      it "raises an error if no dsym source has been found" do
        file_path = File.expand_path('/tmp/wwxfile.dsym.zip')

        expect do
          ENV['DSYM_OUTPUT_PATH'] = nil
          ENV['DSYM_ZIP_PATH'] = nil
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

          Fastlane::Actions::ApteligentAction.dsym_path(params: nil)
        end.to raise_exception "Couldn't find any dSYM file".red
      end

      it "mandatory options are used correctly" do
        ENV['DSYM_OUTPUT_PATH'] = nil
        ENV['DSYM_ZIP_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        file_path = '/tmp/file.dSYM.zip'
        FileUtils.touch file_path
        result = Fastlane::FastFile.new.parse("lane :test do
          apteligent(dsym: '/tmp/file.dSYM.zip',
                      app_id: '123',
                      api_key: 'abc'
                      )
        end").runner.execute(:test)

        expect(result).to include("https://api.crittercism.com/api_beta/dsym/123")
        expect(result).to include("-F file=@/tmp/file.dSYM.zip")
        expect(result).to include("-F key=abc")
      end
    end
  end
end
