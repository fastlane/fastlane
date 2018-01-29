describe Fastlane do
  describe Fastlane::FastFile do
    describe "get_info_plist" do
      let(:plist_path) { "./fastlane/spec/fixtures/plist/Info.plist" }

      it "fetches the value from the plist" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        expect(value).to eq("com.krausefx.app")
      end
    end
  end
end
