describe Fastlane do
  describe Fastlane::FastFile do
    describe "sentry" do
      it "returns uploaded dSYM path" do
        dsym_path_1 = './fastlane/spec/fixtures/dSYM/Themoji.dSYM.zip'

        result = Fastlane::FastFile.new.parse("lane :test do
          upload_symbols_to_sentry(
            api_key: 'something123',
            org_slug: 'some_org',
            project_slug: 'some_project',
            dsym_path: '#{dsym_path_1}')
        end").runner.execute(:test)

        expect(result).to include(dsym_path_1)
      end

      it "returns uploaded dSYM paths" do
        dsym_path_1 = './fastlane/spec/fixtures/dSYM/Themoji.dSYM.zip'
        dsym_path_2 = './fastlane/spec/fixtures/dSYM/This_doesnt_exist_but_doesnt_need_to.dSYM.zip'

        result = Fastlane::FastFile.new.parse("lane :test do
          upload_symbols_to_sentry(
            api_key: 'something123',
            org_slug: 'some_org',
            project_slug: 'some_project',
            dsym_path: '#{dsym_path_1}',
            dsym_paths: ['#{dsym_path_2}'])
        end").runner.execute(:test)

        expect(result).to include(dsym_path_1)
        expect(result).to include(dsym_path_2)
      end
    end
  end
end
