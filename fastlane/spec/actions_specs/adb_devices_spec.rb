describe Fastlane do
  describe Fastlane::FastFile do
    describe "adb_devices" do
      before(:each) do
        adb_response = strip_heredoc(<<-ADB_OUTPUT)
          List of devices attached
          adb server version (39) doesn't match this client (36); killing...
          * daemon started successfully
          T065002LTT             device usb:437387264X product:ghost_retail model:XT1053 device:ghost


        ADB_OUTPUT
        allow(Fastlane::Actions).to receive(:sh).and_return(adb_response)
      end

      it "generates a valid command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          adb_devices(adb_path: '/some/path/to/adb')
        end").runner.execute(:test)

        expect(result.count).to eq(1)
      end

      it "generates a valid command when ANDROID_SDK_ROOT is set" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ENV['ANDROID_SDK_ROOT'] = '/usr/local/android-sdk'
          adb_devices()
        end").runner.execute(:test)

        expect(result.count).to eq(1)
      end
    end
  end
end
