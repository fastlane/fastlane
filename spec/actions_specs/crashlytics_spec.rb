describe Fastlane do
  describe Fastlane::FastFile do
    describe "Crashlytics Integration" do
      it "raises an error if no crashlytics path was given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            crashlytics({
              api_token: 'wadus',
              build_secret: 'wadus',
              ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
            })
          end").runner.execute(:test)
        }.to raise_error("No Crashlytics path given or found, pass using `crashlytics_path: '/path'`".red)
      end

      it "raises an error if the given crashlytics path was not found" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            crashlytics({
              crashlytics_path: './fastlane/wadus',
              api_token: 'wadus',
              build_secret: 'wadus',
              ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
            })
          end").runner.execute(:test)
        }.to raise_error("No Crashlytics path given or found, pass using `crashlytics_path: '/path'`".red)
      end

      it "raises an error if no api token was given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            crashlytics({
              crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              build_secret: 'wadus',
              ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
            })
          end").runner.execute(:test)
        }.to raise_error("No API token for Crashlytics given, pass using `api_token: 'token'`".red)
      end

      it "raises an error if no build secret was given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            crashlytics({
              crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              api_token: 'wadus',
              ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
            })
          end").runner.execute(:test)
        }.to raise_error("No build secret for Crashlytics given, pass using `build_secret: 'secret'`".red)
      end

      it "raises an error if no ipa path was given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            crashlytics({
              crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              api_token: 'wadus',
              build_secret: 'wadus'
            })
          end").runner.execute(:test)
        }.to raise_error("No IPA file given or found, pass using `ipa_path: '/path/app.ipa'`".red)
      end

      it "raises an error if the given ipa path was not found" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            crashlytics({
              crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              api_token: 'wadus',
              build_secret: 'wadus',
              ipa_path: './fastlane/wadus'
            })
          end").runner.execute(:test)
        }.to raise_error("No IPA file given or found, pass using `ipa_path: '/path/app.ipa'`".red)
      end

      it "works with valid parameters" do
        Fastlane::FastFile.new.parse("lane :test do 
          crashlytics({
            crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            api_token: 'wadus',
            build_secret: 'wadus',
            ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
          })
        end").runner.execute(:test)
      end
    end
  end
end
