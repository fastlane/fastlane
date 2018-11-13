describe Fastlane do
  describe Fastlane::FastFile do
    describe "Scan Integration" do
      context ":fail_build" do
        it "raises an error if build/compile error and fail_build is true" do
          allow(Scan).to receive(:config=).and_return(nil)
          allow_any_instance_of(Scan::Manager).to receive(:work).and_raise(FastlaneCore::Interface::FastlaneBuildFailure.new)
          expect do
            Fastlane::FastFile.new.parse("lane :test do
                run_tests(fail_build: true)
              end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneBuildFailure)
        end

        it "raises an error if build/compile error and fail_build is false" do
          allow(Scan).to receive(:config=).and_return(nil)
          allow_any_instance_of(Scan::Manager).to receive(:work).and_raise(FastlaneCore::Interface::FastlaneBuildFailure.new)
          expect do
            Fastlane::FastFile.new.parse("lane :test do
                run_tests(fail_build: false)
              end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneBuildFailure)
        end

        it "raises an error if tests fail and fail_build is true" do
          allow(Scan).to receive(:config=).and_return(nil)
          allow_any_instance_of(Scan::Manager).to receive(:work).and_raise(FastlaneCore::Interface::FastlaneTestFailure.new)
          expect do
            Fastlane::FastFile.new.parse("lane :test do
                run_tests(fail_build: true)
              end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneTestFailure)
        end

        it "does not raise an error if tests fail and fail_build is false" do
          allow(Scan).to receive(:config=).and_return(nil)
          allow_any_instance_of(Scan::Manager).to receive(:work).and_raise(FastlaneCore::Interface::FastlaneTestFailure.new)
          expect do
            Fastlane::FastFile.new.parse("lane :test do
                run_tests(fail_build: false)
              end").runner.execute(:test)
          end.not_to(raise_error)
        end
      end
    end
  end
end
