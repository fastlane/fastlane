require 'fastlane_core/update_checker/update_checker'
require 'fastlane_core/analytics/app_identifier_guesser'

describe FastlaneCore do
  describe FastlaneCore::UpdateChecker do
    let(:name) { 'fastlane' }
    def android_hash_of(value)
      hash_of("android_project_#{value}")
    end

    def hash_of(value)
      Digest::SHA256.hexdigest("p#{value}fastlan3_SAlt")
    end

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
        expect(FastlaneCore::UpdateChecker.update_command(gem_name: "gym")).to eq("sudo gem install gym")
      end

      it "works with system ruby" do
        expect(FastlaneCore::UpdateChecker.update_command).to eq("sudo gem install fastlane")
      end

      it "works with bundler" do
        with_env_values('BUNDLE_BIN_PATH' => '/tmp') do
          expect(FastlaneCore::UpdateChecker.update_command).to eq("bundle update fastlane")
        end
      end

      it "works with bundled fastlane" do
        with_env_values('FASTLANE_SELF_CONTAINED' => 'true') do
          expect(FastlaneCore::UpdateChecker.update_command).to eq("fastlane update_fastlane")
        end
      end

      it "works with Fabric.app installed fastlane" do
        with_env_values('FASTLANE_SELF_CONTAINED' => 'false') do
          expect(FastlaneCore::UpdateChecker.update_command).to eq("the Fabric app. Launch the app and navigate to the fastlane tab to get the most recent version.")
        end
      end
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

    describe "#send_launch_analytic_events_for" do
      before do
        ENV.delete("FASTLANE_OPT_OUT_USAGE")
        allow(FastlaneCore::Helper).to receive(:is_ci?).and_return(false)
      end

      it "sends no events when opted out" do
        with_env_values('FASTLANE_OPT_OUT_USAGE' => 'true') do
          expect(FastlaneCore::UpdateChecker).to_not(receive(:send_events))
          FastlaneCore::UpdateChecker.send_launch_analytic_events_for("fastlane")
        end
      end

      it "has no p_hash event when no project defined" do
        expect(FastlaneCore::UpdateChecker).to receive(:send_events) do |analytics|
          expect(analytics.size).to eq(1)
          expect(analytics.find_all { |a| a[:actor][:detail] == 'fastlane' && a[:action][:name] == 'launched' }.size).to eq(1)
        end

        FastlaneCore::UpdateChecker.send_launch_analytic_events_for("fastlane")
      end

      it "identifies CI correctly" do
        allow(FastlaneCore::Helper).to receive(:is_ci?).and_return(true)

        expect(FastlaneCore::UpdateChecker).to receive(:send_events) do |analytics|
          expect(analytics.size).to eq(1)
          expect(analytics.find_all { |a| a[:primary_target][:detail] == 'true' && a[:action][:name] == 'launched' }.size).to eq(1)
        end

        FastlaneCore::UpdateChecker.send_launch_analytic_events_for("fastlane")
      end

      it "contains p_hash event and uses the bundle identifier and hashes the value if available" do
        ENV["PILOT_APP_IDENTIFIER"] = "com.krausefx.app"
        p_hashed_id = hash_of(ENV["PILOT_APP_IDENTIFIER"])

        expect(FastlaneCore::UpdateChecker).to receive(:send_events) do |analytics|
          expect(analytics.size).to eq(2)
          expect(analytics.find_all { |a| a[:actor][:detail] == 'fastlane' && a[:action][:name] == 'launched' }.size).to eq(1)
          expect(analytics.find_all { |a| a[:actor][:name] == 'project' && a[:action][:name] == 'update_checked' && a[:actor][:detail] == p_hashed_id }.size).to eq(1)
        end

        FastlaneCore::UpdateChecker.send_launch_analytic_events_for("fastlane")
      end
    end

    describe "#send_completion_events_for" do
      before do
        ENV.delete("FASTLANE_OPT_OUT_USAGE")
        allow(FastlaneCore::Helper).to receive(:is_ci?).and_return(false)
      end

      it "sends no events when opted out" do
        with_env_values('FASTLANE_OPT_OUT_USAGE' => 'true') do
          expect(FastlaneCore::UpdateChecker).to_not(receive(:send_events))
          FastlaneCore::UpdateChecker.send_completion_events_for("fastlane")
        end
      end

      it "contains duration event and a install method event" do
        allow(FastlaneCore::UpdateChecker).to receive(:start_time).and_return(Time.now)
        allow(FastlaneCore::Helper).to receive(:rubygems?).and_return(true)
        expect(FastlaneCore::UpdateChecker).to receive(:send_events) do |analytics|
          expect(analytics.size).to eq(2)
          expect(analytics.find_all { |a| a[:actor][:detail] == 'fastlane' && a[:action][:name] == 'completed_with_duration' && a[:primary_target][:detail] }.size).to eq(1)
          expect(analytics.find_all { |a| a[:action][:name] == 'completed_with_install_method' && a[:primary_target][:detail] == 'gem' && a[:secondary_target][:detail] == 'false' }.size).to eq(1)
        end

        FastlaneCore::UpdateChecker.send_completion_events_for("fastlane")
      end
    end
  end
end
