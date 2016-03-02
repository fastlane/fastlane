describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get the app name" do
      fixtures_path = "./fastlane/spec/fixtures/cordova"
      let (:config) { "#{fixtures_path}/config.xml" }

      it "returns the value of the name tag" do
        value = Fastlane::FastFile.new.parse("lane :test do
          cordova_get_app_name(path: '#{config}')
        end").runner.execute(:test)

        expect(value).to eq("Cordova App")
      end
    end
  end
end
