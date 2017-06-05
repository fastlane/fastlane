describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Version Code Integration" do
      require 'shellwords'

      after(:each) do
        # Reset version code
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_code(build_gradle_path: 'fastlane/spec/fixtures/androidproj/app/build.gradle', version_code: '1234')
        end").runner.execute(:test)
      end

      it "increments the version code of the Android project" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_code(build_gradle_path: 'fastlane/spec/fixtures/androidproj/app/build.gradle')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_CODE]).to eq 1235
      end

      it "increments the version code to the version code specified" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_code(build_gradle_path: 'fastlane/spec/fixtures/androidproj/app/build.gradle', version_code: '4321')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_CODE]).to eq 4321
      end
    end
  end
end
