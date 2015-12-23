describe Fastlane do
  describe Fastlane::FastFile do
    describe "Run in simulator" do
      it "works with only scheme name" do
        scheme_name = 'MyLovelyScheme'
        result = Fastlane::FastFile.new.parse("lane :test do
          run_in_simulator({scheme: '#{scheme_name}'})
        end").runner.execute(:test)

        expect(result[0]).to eq("xcrun instruments -s devices | grep -v 'Known Devices:'")
        expect(result[1]).to eq("xcrun instruments -s devices | grep -v 'Known Devices:'")
        expect(result[2]).to eq("killall Simulator")
        expect(result[3]).to eq("open -a Simulator --args -CurrentDeviceUDID ")
        expect(result[4]).to eq("xcrun simctl install  ./run_in_simulator_build/Build/Products/Debug-iphonesimulator/xcodebuild -showBuildSettings -scheme #{scheme_name} | grep FULL_PRODUCT_NAME")
        expect(result[5]).to eq("xcrun simctl launch  xcodebuild -showBuildSettings -scheme #{scheme_name} | grep PRODUCT_BUNDLE_IDENTIFIER")
      end

      it "works with scheme name and device name" do
        scheme_name = 'MyLovelyScheme'
        device_name = 'iPhone 5'
        result = Fastlane::FastFile.new.parse("lane :test do
          run_in_simulator({scheme: '#{scheme_name}', device_name:'iPhone 5'})
        end").runner.execute(:test)

        expect(result[0]).to eq("xcrun instruments -s devices | grep -v 'Known Devices:' | grep 'iPhone 5 ('")
        expect(result[1]).to eq("xcrun instruments -s devices | grep -v 'Known Devices:' | grep 'iPhone 5 ('")
        expect(result[2]).to eq("killall Simulator")
        expect(result[3]).to eq("open -a Simulator --args -CurrentDeviceUDID ")
        expect(result[4]).to eq("xcrun simctl install  ./run_in_simulator_build/Build/Products/Debug-iphonesimulator/xcodebuild -showBuildSettings -scheme #{scheme_name} | grep FULL_PRODUCT_NAME")
        expect(result[5]).to eq("xcrun simctl launch  xcodebuild -showBuildSettings -scheme #{scheme_name} | grep PRODUCT_BUNDLE_IDENTIFIER")
      end

      it "works with scheme name and device name, ios version and device id" do
        scheme_name = 'MyLovelyScheme'
        device_name = 'iPhone 5'
        ios_version = '9.2'
        device_id = 'MY_DEVICE_UDID'
        result = Fastlane::FastFile.new.parse("lane :test do
          run_in_simulator({scheme: '#{scheme_name}', device_name:'iPhone 5', ios_version:'#{ios_version}', device_id:'#{device_id}'})
        end").runner.execute(:test)

        expect(result[0]).to eq("xcrun instruments -s devices | grep -v 'Known Devices:' | grep 'iPhone 5 (' | grep 'MY_DEVICE_UDID' | grep '9.2'")
        expect(result[1]).to eq("xcrun instruments -s devices | grep -v 'Known Devices:' | grep 'iPhone 5 (' | grep 'MY_DEVICE_UDID' | grep '9.2'")
        expect(result[2]).to eq("killall Simulator")
        expect(result[3]).to eq("open -a Simulator --args -CurrentDeviceUDID ")
        expect(result[4]).to eq("xcrun simctl install  ./run_in_simulator_build/Build/Products/Debug-iphonesimulator/xcodebuild -showBuildSettings -scheme #{scheme_name} | grep FULL_PRODUCT_NAME")
        expect(result[5]).to eq("xcrun simctl launch  xcodebuild -showBuildSettings -scheme #{scheme_name} | grep PRODUCT_BUNDLE_IDENTIFIER")
      end
    end
  end
end
