describe Fastlane do
  describe Fastlane::FastFile do
    describe "upload_symbols_to_crashlytics" do
      it "extracts zip files" do
        binary_path = './fastlane/spec/fixtures/screenshots/screenshot1.png'
        dsym_path = './fastlane/spec/fixtures/dSYM/Themoji.dSYM.zip'

        expect(Fastlane::Actions).to receive(:sh).with("unzip -qo #{File.expand_path(dsym_path).shellescape}")

        Fastlane::FastFile.new.parse("lane :test do
          upload_symbols_to_crashlytics(
            dsym_path: '#{dsym_path}',
            api_token: 'something123',
            binary_path: '#{binary_path}')
        end").runner.execute(:test)
      end

      it "uploads dSYM files" do
        binary_path = './spec/fixtures/screenshots/screenshot1.png'
        dsym_path = './spec/fixtures/dSYM/Themoji.dSYM'

        command = []
        command << File.expand_path(File.join("fastlane", binary_path)).shellescape
        command << "-a something123"
        command << "-p ios"
        command << File.expand_path(File.join("fastlane", dsym_path)).shellescape

        expect(Fastlane::Actions).to receive(:sh).with(command.join(" "), log: false)

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
