describe Fastlane do
  describe Fastlane::FastFile do
    describe "Sonar Integration" do
      it "Should not print sonar command" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expected_command = "cd #{File.expand_path('.').shellescape} && sonar-scanner -Dsonar.login=\"asdf\""
        expect(Fastlane::Actions::SonarAction).to receive(:verify_sonar_scanner_binary).and_return(true)
        expect(Fastlane::Actions).to receive(:sh_control_output).with(expected_command, print_command: false, print_command_output: true).and_call_original
        Fastlane::FastFile.new.parse("lane :sonar_test do
          sonar(sonar_login: 'asdf')
        end").runner.execute(:sonar_test)
      end
    end
  end
end
