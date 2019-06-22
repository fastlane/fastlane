require 'fastlane_core/update_checker/update_checker'

describe FastlaneCore do
  describe FastlaneCore::UpdateChecker do
    let(:name) { 'fastlane' }

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
        FastlaneSpec::Env.with_env_values('BUNDLE_BIN_PATH' => '/tmp') do
          expect(FastlaneCore::UpdateChecker.update_command).to eq("bundle update fastlane")
        end
      end

      it "works with bundled fastlane" do
        FastlaneSpec::Env.with_env_values('FASTLANE_SELF_CONTAINED' => 'true') do
          expect(FastlaneCore::UpdateChecker.update_command).to eq("fastlane update_fastlane")
        end
      end

      it "works with Fabric.app installed fastlane" do
        FastlaneSpec::Env.with_env_values('FASTLANE_SELF_CONTAINED' => 'false') do
          expect(FastlaneCore::UpdateChecker.update_command).to eq("the Fabric app. Launch the app and navigate to the fastlane tab to get the most recent version.")
        end
      end
    end
  end
end
