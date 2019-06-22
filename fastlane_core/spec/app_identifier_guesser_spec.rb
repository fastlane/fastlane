require 'fastlane_core/analytics/app_identifier_guesser'

describe FastlaneCore do
  describe FastlaneCore::AppIdentifierGuesser do
    def android_hash_of(value)
      hash_of("android_project_#{value}")
    end

    def hash_of(value)
      Digest::SHA256.hexdigest("p#{value}fastlan3_SAlt")
    end

    describe "#p_hash?" do
      let(:package_name) { 'com.test.app' }

      before do
        ENV.delete("FASTLANE_OPT_OUT_USAGE")
      end

      it "chooses the correct param for package name for supply" do
        args = ["--skip_upload_screenshots", "-a", "beta", "-p", package_name]
        guesser = FastlaneCore::AppIdentifierGuesser.new(args: args, gem_name: 'supply')

        expect(guesser.p_hash).to eq(android_hash_of(package_name))
      end

      it "chooses the correct param for package name for screengrab" do
        args = ["--skip_open_summary", "-a", package_name, "-p", "com.test.app.test"]

        guesser = FastlaneCore::AppIdentifierGuesser.new(args: args, gem_name: 'screengrab')
        expect(guesser.p_hash).to eq(android_hash_of(package_name))
      end

      it "chooses the correct param for package name for gym" do
        args = ["--clean", "-a", package_name, "-p", "test.xcodeproj"]
        guesser = FastlaneCore::AppIdentifierGuesser.new(args: args, gem_name: 'gym')
        expect(guesser.p_hash).to eq(hash_of(package_name))
      end
    end
  end
end
