describe Fastlane do
  describe Fastlane::FastFile do
    describe "cordova_get_config_value" do
      let (:cordova_config_path) { "./fastlane/spec/fixtures/cordova/config.xml" }

      it "fetches the value attribute from the config file" do
        value = Fastlane::FastFile.new.parse("lane :test do
          cordova_get_config_value(path: '#{cordova_config_path}', key: 'id')
        end").runner.execute(:test)

        expect(value).to eq("tools.fastlane.cordova")
      end
    end
  end
end
