describe Fastlane do
  describe Fastlane::FastFile do
    describe "upload_symbols_to_crashlytics" do
      it "generates a valid command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          upload_symbols_to_crashlytics(
            dsym_path: './fastlane/spec/fixtures/dSYM/Themoji.dSYM.zip',
            api_token: 'something123',
            binary_path: './fastlane/spec/fixtures/screenshots/screenshot1.png')
        end").runner.execute(:test)

        expect(result).to include("screenshot1.png")
        expect(result).to include("-a something123 -p ios")
        expect(result).to include("dSYM/Themoji.dSYM.zip")
      end
    end
  end
end
