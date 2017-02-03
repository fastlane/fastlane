require 'scan'

describe Scan do
  describe Scan::Runner do
    describe "handle_results" do
      before(:each) do
        mock_slack_poster = Object.new
        allow(Scan::SlackPoster).to receive(:new).and_return(mock_slack_poster)
        allow(mock_slack_poster).to receive(:run)
        allow(Scan::TestCommandGenerator).to receive(:xcodebuild_log_path).and_return('./scan/spec/fixtures/boring.log')
        @scan = Scan::Runner.new
      end

      describe "without Scan option :include_simulator_logs" do
        it "does not copy any device logs to the output directory" do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            output_directory: '/tmp/scan_results',
            project: './scan/examples/standard/app.xcodeproj'
          })
          expect(FileUtils).not_to receive(:cp)
          @scan.handle_results(0)
        end
      end
    end
  end
end
