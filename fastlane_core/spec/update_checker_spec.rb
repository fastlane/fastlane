require 'fastlane_core/update_checker/update_checker'

describe FastlaneCore do
  describe FastlaneCore::UpdateChecker do
    let (:name) { 'fastlane' }

    describe "#update_available?" do
      it "no update is available" do
        FastlaneCore::UpdateChecker.server_results[name] = '0.1'
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.11')).to eq(false)
      end

      it "new update is available" do
        FastlaneCore::UpdateChecker.server_results[name] = '999.0'
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.11')).to eq(true)
      end

      it "same version" do
        FastlaneCore::UpdateChecker.server_results[name] = Fastlane::VERSION
        expect(FastlaneCore::UpdateChecker.update_available?(name, Fastlane::VERSION)).to eq(false)
      end

      it "new pre-release" do
        FastlaneCore::UpdateChecker.server_results[name] = [Fastlane::VERSION, 'pre'].join(".")
        expect(FastlaneCore::UpdateChecker.update_available?(name, Fastlane::VERSION)).to eq(false)
      end

      it "current: Pre-Release - new official version" do
        FastlaneCore::UpdateChecker.server_results[name] = '0.9.1'
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.1.pre')).to eq(true)
      end

      it "a new pre-release when pre-release is installed" do
        FastlaneCore::UpdateChecker.server_results[name] = '0.9.1.pre2'
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.1.pre1')).to eq(true)
      end
    end

    describe "#update_command" do
      before do
        ENV.delete("BUNDLE_BIN_PATH")
        ENV.delete("BUNDLE_GEMFILE")
      end

      it "works a custom gem name" do
        expect(FastlaneCore::UpdateChecker.update_command(gem_name: "gym")).to eq("sudo gem update gym")
      end

      it "works with system ruby" do
        expect(FastlaneCore::UpdateChecker.update_command).to eq("sudo gem update fastlane")
      end

      it "works with bundler" do
        ENV["BUNDLE_BIN_PATH"] = "/tmp"
        expect(FastlaneCore::UpdateChecker.update_command).to eq("bundle update fastlane")
      end

      it "works with bundled fastlane" do
        ENV["FASTLANE_SELF_CONTAINED"] = "true"
        expect(FastlaneCore::UpdateChecker.update_command).to eq("fastlane update_fastlane")
      end
    end

    describe "#p_hash?" do
      let (:package_name) { 'com.test.app' }

      def android_hash_of(value)
        hash_of("android_project_#{value}")
      end

      def hash_of(value)
        Digest::SHA256.hexdigest("p#{value}fastlan3_SAlt")
      end

      it "chooses the correct param for package name for supply" do
        args = ["--skip_upload_screenshots", "-a", "beta", "-p", package_name]
        expect(FastlaneCore::UpdateChecker.p_hash(args, 'supply')).to eq(android_hash_of(package_name))
      end

      it "chooses the correct param for package name for screengrab" do
        args = ["--skip_open_summary", "-a", package_name, "-p", "com.test.app.test"]
        expect(FastlaneCore::UpdateChecker.p_hash(args, 'screengrab')).to eq(android_hash_of(package_name))
      end

      it "chooses the correct param for package name for gym" do
        args = ["--clean", "-a", package_name, "-p", "test.xcodeproj"]
        expect(FastlaneCore::UpdateChecker.p_hash(args, 'gym')).to eq(hash_of(package_name))
      end
    end

    describe "#generate_fetch_url" do
      before do
        ENV.delete("FASTLANE_OPT_OUT_USAGE")
        expect(FastlaneCore::Helper).to receive(:is_ci?).and_return(false)
      end

      it "generated the correct URL with no parameters, no platform value and no p_hash" do
        expect(FastlaneCore::UpdateChecker.generate_fetch_url("fastlane")).to eq("https://fastlane-refresher.herokuapp.com/fastlane")
      end

      it "uses the bundle identifier and hashes the value if available" do
        ENV["PILOT_APP_IDENTIFIER"] = "com.krausefx.app"
        expect(FastlaneCore::UpdateChecker.generate_fetch_url("fastlane")).to eq("https://fastlane-refresher.herokuapp.com/fastlane?p_hash=50925b8f18defc356dad507b1729bc185f9582513537346424b0be09b1f12b2f&platform=ios")
      end

      describe "#platform" do
        it "ios" do
          ARGV = ["--app_identifier", "yolo.app"]
          expect(FastlaneCore::UpdateChecker.generate_fetch_url("sigh")).to eq("https://fastlane-refresher.herokuapp.com/sigh?p_hash=52629c9a0eebe49c58db83c94c090bd790a101ff2a70ab9514f6a6427644375a&platform=ios")
        end

        it "android" do
          ARGV = ["--app_package_name", "yolo.android.app"]
          expect(FastlaneCore::UpdateChecker.generate_fetch_url("supply")).to eq("https://fastlane-refresher.herokuapp.com/supply?p_hash=6a8b842e4a75d2a2bc4bdf584406a68eab8cabcc7b7a396c283b390fff30b59b&platform=android")
        end
      end
    end
  end
end
