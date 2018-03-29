describe Fastlane do
  describe Fastlane::FastFile do
    describe "adb" do
      it "generates a valid command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          adb(command: 'test', adb_path: './fastlane/README.md')
        end").runner.execute(:test)

        expect(result).to eq(" ./fastlane/README.md test")
      end

      it "picks up path from android_home" do
        result = Fastlane::FastFile.new.parse("lane :test do
          adb(command: 'test', android_home: '/usr/local/android-sdk')
        end").runner.execute(:test)

        expect(result).to eq(" /usr/local/android-sdk/platform-tools/adb test")
      end
    end
  end
end
