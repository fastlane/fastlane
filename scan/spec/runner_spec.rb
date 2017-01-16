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

      describe "with Scan option :include_simulator_logs" do
        before(:each) do
          allow(File).to receive(:exist?).and_return(true)

          allow(FileUtils).to receive(:cp).with(anything, anything) do
            # nothing
          end
        end

        context "and only one device requested" do
          it "copies one simulated device log to the output directory" do
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
              output_directory: '/tmp/scan_results',
              include_simulator_logs: true,
              device: 'iPhone 5s (10.2)',
              project: './scan/examples/standard/app.xcodeproj'
            })

            expect(FileUtils).to receive(:cp).with(/.*/, %r{#{Scan.config[:output_directory]}\/iPhone .*_iOS_.*system.log})
            @scan.handle_results(0)
          end
        end

        context "and more than one device requested" do
          it "copies all device logs to the output directory" do
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
              output_directory: '/tmp/scan_results',
              include_simulator_logs: true,
              devices: ["iPhone 6s", "iPad Air"],
              project: './scan/examples/standard/app.xcodeproj'
            })
            expect(FileUtils).to receive(:cp).with(/.*/, %r{#{Scan.config[:output_directory]}\/iPhone .*_iOS_.*system.log})
            expect(FileUtils).to receive(:cp).with(/.*/, %r{#{Scan.config[:output_directory]}\/iPad Air_iOS_.*system.log})
            @scan.handle_results(0)
          end
        end
      end
    end
  end
end
