describe Fastlane do
  describe Fastlane::FastFile do
    describe "Trainer Integration" do
      # Avoid fixed paths under /tmp: parallel test processes would share them. See fastlane#30184.
      let(:output_directory) { Dir.mktmpdir("fl_spec_trainer") }
      after { FileUtils.remove_entry(output_directory) if File.directory?(output_directory) }

      context ":fail_build" do
        it "does not raise an error if tests fail and fail_build is false", requires_xcode: true do
          expect do
            Fastlane::FastFile.new.parse("lane :parse_test_result do
                trainer(
                  path: '../trainer/spec/fixtures/Test.test_result.xcresult',
                  output_directory: '#{output_directory}',
                  fail_build: false
                )
              end").runner.execute(:parse_test_result)
          end.not_to(raise_error)
        end

        it "raises an error if tests fail and fail_build is true", requires_xcode: true do
          failing_xcresult_path = "../trainer/spec/fixtures/Test.test_result.xcresult"
          expect do
            Fastlane::FastFile.new.parse("lane :parse_test_result do
                trainer(
                  path: '../trainer/spec/fixtures/Test.test_result.xcresult',
                  output_directory: '#{output_directory}',
                  fail_build: true
                )
              end").runner.execute(:parse_test_result)
          end.to raise_error(FastlaneCore::Interface::FastlaneTestFailure)
        end
      end
    end
  end
end
