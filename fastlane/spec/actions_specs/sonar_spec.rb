describe Fastlane do
  describe Fastlane::FastFile do
    describe "Sonar Scanner" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "Should verify sonar-scanner is installed" do
        expect(Fastlane::Actions::SonarAction).to receive(:verify_sonar_scanner_binary).and_return(true)

        Fastlane::FastFile.new.parse("lane :sonar_test do
          sonar
        end").runner.execute(:sonar_test)
      end

      it "Should not print sonar command" do
        expected_command = "sonar-scanner -Dsonar.login=\"asdf\""
        expect(Fastlane::Actions).to receive(:sh_control_output).with(expected_command, print_command: false, print_command_output: true).and_call_original

        Fastlane::FastFile.new.parse("lane :sonar_test do
          sonar(sonar_login: 'asdf')
        end").runner.execute(:sonar_test)
      end

      it "Should not print any output" do
        expected_command = "sonar-scanner -Dsonar.login=\"asdf\""
        expect(Fastlane::Actions).to receive(:sh_control_output).with(expected_command, print_command: false, print_command_output: false).and_call_original

        Fastlane::FastFile.new.parse("lane :sonar_test do
          sonar(sonar_login: 'asdf', verbose: false)
        end").runner.execute(:sonar_test)
      end
    end
  end
end
