describe Fastlane do
  describe Fastlane::FastFile do
    describe "upload_symbols_to_crashlytics" do
      it "generates a valid command" do
        binary_path = './spec/fixtures/screenshots/screenshot1.png'
        dsym_path = './spec/fixtures/dSYM/Themoji.dSYM.zip'

        command = []
        command << File.expand_path(binary_path)
        command << "-a something123"
        command << "-p ios"
        command << File.expand_path(dsym_path)

        expect(Fastlane::Actions).to receive(:sh).with(command.join(" "))

        Fastlane::FastFile.new.parse("lane :test do
          upload_symbols_to_crashlytics(
            dsym_path: 'fastlane/#{dsym_path}',
            api_token: 'something123',
            binary_path: 'fastlane/#{binary_path}')
        end").runner.execute(:test)
      end
    end
  end
end
