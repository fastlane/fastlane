require 'scan'

describe Scan do
  describe Scan::ErrorHandler do
    describe "handle_build_error" do
      describe "when parsing parallel test failure output" do
        it "does not report a build failure" do
          output = File.open('./scan/spec/fixtures/parallel_testing_failure.log', &:read)
          expect do
            Scan::ErrorHandler.handle_build_error(output)
          end.to_not(raise_error(FastlaneCore::Interface::FastlaneBuildFailure))
        end
      end
      describe "when parsing non-parallel test failure output" do
        it "does not report a build failure" do
          output = File.open('./scan/spec/fixtures/non_parallel_testing_failure.log', &:read)
          expect do
            Scan::ErrorHandler.handle_build_error(output)
          end.to_not(raise_error(FastlaneCore::Interface::FastlaneBuildFailure))
        end
      end
      describe "when parsing early failure output" do
        it "reports a build failure" do
          output = File.open('./scan/spec/fixtures/early_testing_failure.log', &:read)
          expect do
            Scan::ErrorHandler.handle_build_error(output)
          end.to(raise_error(FastlaneCore::Interface::FastlaneBuildFailure))
        end
      end
    end
  end
end
