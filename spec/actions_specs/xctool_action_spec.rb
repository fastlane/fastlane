describe Fastlane do
  describe Fastlane::FastFile do
    describe "xctool Integration" do
      it "works with no parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          xctool
        end").runner.execute(:test)

        expect(result).to eq("xctool ")
      end

      it "works with default setting" do
        result = Fastlane::FastFile.new.parse("lane :test do
          xctool 'build test'
        end").runner.execute(:test)

        expect(result).to eq("xctool build test")
      end

      it "works with default setting" do
        result = Fastlane::FastFile.new.parse('lane :test do
          xctool :test, [
            "--workspace", "\'AwesomeApp.xcworkspace\'",
            "--scheme", "\'Schema Name\'",
            "--configuration", "Debug",
            "--sdk", "iphonesimulator",
            "--arch", "i386"
          ].join(" ")
        end').runner.execute(:test)

        expect(result).to eq("xctool test --workspace 'AwesomeApp.xcworkspace' --scheme 'Schema Name' --configuration Debug --sdk iphonesimulator --arch i386")
      end
    end
  end
end
