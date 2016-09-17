describe Fastlane do
  describe Fastlane::FastFile do
    describe "adb_devices" do
      it "generates a valid command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          adb_devices(adb_path: './fastlane/README.md')
        end").runner.execute(:test)

        expect(result).to match_array([])
      end
    end
  end
end
