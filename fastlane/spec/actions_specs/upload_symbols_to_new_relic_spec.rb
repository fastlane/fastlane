describe Fastlane do
  describe Fastlane::FastFile do
    describe "upload_symbols_to_new_relic" do
      it "converts dwarf dump output to hash map" do
        action = Fastlane::Actions::UploadSymbolsToNewRelicAction
        test_dwarf_dump_line = "UUID: ABC-123-DEF-4G56-HIJ (amv7s) path/to/TestLibName"
        result = action.transform_architecture_symbol_info(test_dwarf_dump_line)
        expect(result[:uuid]).to eq("abc123def4g56hij")
        expect(result[:lib_name]).to eq("TestLibName")
      end

      it "extracts zip files" do
        binary_path = './spec/fixtures/screenshots/screenshot1.png'
        dsym_path = './spec/fixtures/dSYM/Themoji.dSYM.zip'

        expect(Fastlane::Actions).to receive(:sh).with("unzip -qo #{File.expand_path(dsym_path)}")

        Fastlane::FastFile.new.parse("lane :test do
          upload_symbols_to_new_relic(
            dsym_path: 'fastlane/#{dsym_path}',
            new_relic_license_key: 'something123',
            new_relic_app_name: 'TestAppName',
            new_relic_upload_libs: 'TestAppName')
        end").runner.execute(:test)
      end

      it "uploads dSYM files" do
        binary_path = './spec/fixtures/screenshots/screenshot1.png'
        dsym_path = './spec/fixtures/dSYM/Themoji.dSYM'

        expect(Fastlane::Actions).to receive(:sh).with("xcrun dwarfdump --uuid #{File.expand_path(dsym_path)}")

        Fastlane::FastFile.new.parse("lane :test do
          upload_symbols_to_new_relic(
            dsym_path: 'fastlane/#{dsym_path}',
            new_relic_license_key: 'something123',
            new_relic_app_name: 'TestAppName',
            new_relic_upload_libs: 'todoappgame')
        end").runner.execute(:test)
      end
    end
  end
end
