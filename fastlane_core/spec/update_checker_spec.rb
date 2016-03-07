require 'fastlane_core/update_checker/update_checker'

describe FastlaneCore do
  describe FastlaneCore::UpdateChecker do
    let (:name) { 'deliver' }

    describe "#update_available?" do
      it "no update is available" do
        FastlaneCore::UpdateChecker.server_results['deliver'] = '0.1'
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.11')).to eq(false)
      end

      it "new update is available" do
        FastlaneCore::UpdateChecker.server_results['deliver'] = '999.0'
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.11')).to eq(true)
      end

      it "same version" do
        FastlaneCore::UpdateChecker.server_results['deliver'] = FastlaneCore::VERSION
        expect(FastlaneCore::UpdateChecker.update_available?(name, FastlaneCore::VERSION)).to eq(false)
      end

      it "new pre-release" do
        FastlaneCore::UpdateChecker.server_results['deliver'] = [FastlaneCore::VERSION, 'pre'].join(".")
        expect(FastlaneCore::UpdateChecker.update_available?(name, FastlaneCore::VERSION)).to eq(false)
      end

      it "current: Pre-Release - new official version" do
        FastlaneCore::UpdateChecker.server_results['deliver'] = '0.9.1'
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.1.pre')).to eq(true)
      end

      it "a new pre-release when pre-release is installed" do
        FastlaneCore::UpdateChecker.server_results['deliver'] = '0.9.1.pre2'
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.1.pre1')).to eq(true)
      end
    end
  end
end
