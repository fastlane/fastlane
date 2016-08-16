describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get the app id" do
      fixtures_path = "./fastlane/spec/fixtures/cordova"
      let (:config) { "#{fixtures_path}/config.xml" }
      let (:config_with_platform_id) { "#{fixtures_path}/config_platform_id.xml" }

      it "returns the app id" do
        value = Fastlane::FastFile.new.parse("lane :test do
          cordova_get_app_id(path: '#{config}')
        end").runner.execute(:test)

        expect(value).to eq("tools.fastlane.cordova")
      end

      describe "from android platform" do
        it "return the android app id" do
          value = Fastlane::FastFile.new.parse("lane :test do
            cordova_get_app_id(path: '#{config_with_platform_id}', platform: :android)
          end").runner.execute(:test)

          expect(value).to eq("tools.fastlane.cordova.android")
        end

        it "return the app value if android-packageName not exists" do
          value = Fastlane::FastFile.new.parse("lane :test do
            cordova_get_app_id(path: '#{config}', platform: :android)
          end").runner.execute(:test)

          expect(value).to eq("tools.fastlane.cordova")
        end
      end

      describe "from ios platform" do
        it "return the ios app id" do
          value = Fastlane::FastFile.new.parse("lane :test do
            cordova_get_app_id(path: '#{config_with_platform_id}', platform: :ios)
          end").runner.execute(:test)

          expect(value).to eq("tools.fastlane.cordova.ios")
        end

        it "return the id value if ios-CFBundleIdentifier not exists" do
          value = Fastlane::FastFile.new.parse("lane :test do
            cordova_get_app_id(path: '#{config}', platform: :android)
          end").runner.execute(:test)

          expect(value).to eq("tools.fastlane.cordova")
        end
      end
    end
  end
end
