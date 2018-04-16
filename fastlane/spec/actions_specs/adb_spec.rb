describe Fastlane do
  describe Fastlane::FastFile do
    describe "adb" do
      before(:each) do
        ENV['ANDROID_HOME'] = nil
        ENV['ANDROID_SDK_ROOT'] = nil
        ENV['ANDROID_SDK'] = nil
      end

      it "generates a valid command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          adb(command: 'test', adb_path: './fastlane/README.md')
        end").runner.execute(:test)

        expect(result).to eq(" ./fastlane/README.md test")
      end

      it "picks up path from ANDROID_HOME environment variable" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ENV['ANDROID_HOME'] = '/usr/local/android-sdk'
          adb(command: 'test')
        end").runner.execute(:test)

        expect(result).to eq(" /usr/local/android-sdk/platform-tools/adb test")
      end

      it "picks up path from ANDROID_SDK_ROOT environment variable" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ENV['ANDROID_SDK_ROOT'] = '/usr/local/android-sdk'
          adb(command: 'test')
        end").runner.execute(:test)

        expect(result).to eq(" /usr/local/android-sdk/platform-tools/adb test")
      end

      it "picks up path from ANDROID_SDK environment variable" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ENV['ANDROID_SDK'] = '/usr/local/android-sdk'
          adb(command: 'test')
        end").runner.execute(:test)

        expect(result).to eq(" /usr/local/android-sdk/platform-tools/adb test")
      end
    end
  end
end
