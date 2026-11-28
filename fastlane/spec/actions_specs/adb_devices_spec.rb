describe Fastlane do
  describe Fastlane::FastFile do
    describe "adb_devices" do
      it "generates an empty list of devices" do
        result = Fastlane::FastFile.new.parse("lane :test do
          adb_devices(adb_path: '/some/path/to/adb')
        end").runner.execute(:test)

        expect(result).to match_array([])
      end

      it "generates an empty list of devices when ANDROID_SDK_ROOT is set" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ENV['ANDROID_SDK_ROOT'] = '/usr/local/android-sdk'
          adb_devices()
        end").runner.execute(:test)

        expect(result).to match_array([])
      end

      it "calls AdbHelper for loading all the devices" do
        expect_any_instance_of(Fastlane::Helper::AdbHelper).to receive(:load_all_devices).and_return([1, 2, 3])

        result = Fastlane::FastFile.new.parse("lane :test do
          adb_devices
        end").runner.execute(:test)

        expect(result).to match_array([1, 2, 3])
      end
    end
  end
end
