require 'scan'

describe Scan do
  describe Scan::Runner do
    before(:each) do
      fake_out_simulator_detection
      fake_out_build_settings(SCAN_BUILD_SETTINGS)
    end

    describe "handle_results" do
      # handle_results reads the test results from the result bundle whose path TestCommandGenerator stores.
      # These specs don't run TestCommandGenerator, so they store one themselves. Trainer is stubbed, so no bundle has to be there.
      def configure(options = {})
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
          output_directory: '/tmp/scan_results',
          project: './scan/examples/standard/app.xcodeproj'
        }.merge(options))
        Scan.cache[:result_bundle_path] = '/tmp/scan_results/test.xcresults'
      end

      def stub_test_results(failures:)
        allow(Trainer::TestParser).to receive(:auto_convert).and_return({
          "some/path": {
            successful: failures.zero?,
            number_of_tests: 10,
            number_of_failures: failures,
            number_of_tests_excluding_retries: 10,
            number_of_failures_excluding_retries: failures,
            number_of_retries: 0
          }
        })
      end

      before(:each) do
        mock_slack_poster = Object.new
        allow(Scan::SlackPoster).to receive(:new).and_return(mock_slack_poster)
        allow(mock_slack_poster).to receive(:run)

        mock_test_command_generator = Object.new
        allow(Scan::TestCommandGenerator).to receive(:new).and_return(mock_test_command_generator)
        allow(mock_test_command_generator).to receive(:xcodebuild_log_path).and_return('./scan/spec/fixtures/boring.log')

        mock_test_result_parser = Object.new
        allow(Scan::TestResultParser).to receive(:new).and_return(mock_test_result_parser)
        allow(mock_test_result_parser).to receive(:parse_result).and_return({ tests: 100, failures: 0 })

        stub_test_results(failures: 0)

        @scan = Scan::Runner.new
      end

      describe "with scan option :include_simulator_logs set to false" do
        it "does not copy any device logs to the output directory", requires_xcodebuild: true do
          configure(include_simulator_logs: false)

          expect(FastlaneCore::Simulator).not_to(receive(:copy_logs))
          @scan.handle_results(0)
        end
      end

      describe "with scan option :include_simulator_logs set to true" do
        it "copies any device logs to the output directory", requires_xcodebuild: true do
          configure(include_simulator_logs: true)

          expect(FastlaneCore::Simulator).to receive(:copy_logs)
          @scan.handle_results(0)
        end
      end

      describe "with scan option :include_simulator_logs set to on-failure" do
        before(:each) do
          configure(include_simulator_logs: 'on-failure')
        end

        it "does not copy any device logs when the tests pass", requires_xcodebuild: true do
          expect(FastlaneCore::Simulator).not_to(receive(:copy_logs))
          @scan.handle_results(0)
        end

        it "copies the device logs before reporting failed tests", requires_xcodebuild: true do
          stub_test_results(failures: 1)

          expect(FastlaneCore::Simulator).to receive(:copy_logs)
          expect do
            @scan.handle_results(65)
          end.to raise_error(FastlaneCore::Interface::FastlaneTestFailure, "Tests have failed")
        end

        it "copies the device logs when xcodebuild failed and the results can't be read", requires_xcodebuild: true do
          allow(Trainer::TestParser).to receive(:auto_convert).and_raise("Trainer couldn't parse the result bundle")

          expect(FastlaneCore::Simulator).to receive(:copy_logs)
          expect do
            @scan.handle_results(65)
          end.to raise_error("Trainer couldn't parse the result bundle")
        end

        it "copies the device logs when only the results show failed tests", requires_xcodebuild: true do
          stub_test_results(failures: 1)

          expect(FastlaneCore::Simulator).to receive(:copy_logs)
          expect do
            @scan.handle_results(0)
          end.to raise_error(FastlaneCore::Interface::FastlaneTestFailure, "Tests have failed")
        end
      end

      describe "with scan option :force_legacy_xcresulttool set to true" do
        it "forwards force_legacy_xcresulttool to trainer", requires_xcodebuild: true do
          configure(force_legacy_xcresulttool: true)

          expect(Trainer::TestParser).to receive(:auto_convert).with(hash_including(force_legacy_xcresulttool: true)).and_return({})
          @scan.handle_results(0)
        end
      end

      describe "Test Failure" do
        it "raises a FastlaneTestFailure instead of a crash or UserError", requires_xcodebuild: true do
          expect do
            configure
            stub_test_results(failures: 1)

            @scan.handle_results(0)
          end.to raise_error(FastlaneCore::Interface::FastlaneTestFailure, "Tests have failed")
        end
      end

      describe "when handling result" do
        it "returns output if fail_build is false", requires_xcodebuild: true do
          configure(fail_build: false)
          stub_test_results(failures: 1)

          expect(@scan.handle_results(0)).to eq({
            number_of_tests: 10,
            number_of_failures: 1,
            number_of_skipped: 0,
            number_of_tests_excluding_retries: 10,
            number_of_failures_excluding_retries: 1,
            number_of_retries: 0
        })
        end
      end

      describe "with scan option :disable_xcpretty set to true" do
        it "does not generate a temp junit report", requires_xcodebuild: true do
          configure(disable_xcpretty: true)

          Scan.cache[:temp_junit_report] = '/var/folders/non_existent_file.junit'
          @scan.handle_results(0)
          expect(Scan.cache[:temp_junit_report]).to(eq('/var/folders/non_existent_file.junit'))
        end

        it "fails if tests_exit_status is not 0", requires_xcodebuild: true do
          expect do
            configure(disable_xcpretty: true)

            @scan.handle_results(1)
          end.to raise_error(FastlaneCore::Interface::FastlaneTestFailure, "Test execution failed. Exit status: 1")
        end
      end

      describe "when :build_for_testing is true" do
        it "fails the run if xcodebuild exits with a non-zero status even when error output contains 'Executed'", requires_xcodebuild: true do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            output_directory: '/tmp/scan_results',
            project: './scan/examples/standard/app.xcodeproj',
            build_for_testing: true,
            fail_build: true
          })

          test_command_generator = @scan.instance_variable_get(:@test_command_generator)
          allow(test_command_generator).to receive(:generate).and_return("xcodebuild build-for-testing")

          error_output = <<~ERROR
            Some random xcodebuild failure output
            /tmp/MyAppTestsFileThatContainsWordExecuted.swift:12: error: Something broke
          ERROR

          expect(Scan::ErrorHandler).to receive(:handle_build_error).with(error_output, anything).and_call_original

          allow(FastlaneCore::CommandExecutor).to receive(:execute) do |error:, **|
            error.call(error_output, 65)
            ""
          end

          expect do
            @scan.run
          end.to raise_error(FastlaneCore::Interface::FastlaneBuildFailure, "Build for testing failed. Exit status: 65")
        end

        it "reports the failed build before looking for a .xctestrun file to copy", requires_xcodebuild: true do
          Dir.mktmpdir do |derived_data_path|
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
              output_directory: '/tmp/scan_results',
              project: './scan/examples/standard/app.xcodeproj',
              derived_data_path: derived_data_path,
              build_for_testing: true,
              output_xctestrun: true
            })

            expect do
              @scan.handle_results(65)
            end.to raise_error(FastlaneCore::Interface::FastlaneBuildFailure, "Build for testing failed. Exit status: 65")
          end
        end
      end
    end

    describe "#prelaunch_simulators" do
      # Xcode's headless mode shuts the simulators down before their logs could be collected
      it "prelaunches the simulators when their logs are collected only on failure" do
        allow(Scan).to receive(:config).and_return(FastlaneCore::Configuration.create(Scan::Options.available_options, {
          prelaunch_simulator: false,
          include_simulator_logs: 'on-failure'
        }))

        # Already booted, so there's nothing to shut down when the specs exit
        simulator = FastlaneCore::DeviceManager::Device.new(name: "iPhone 15", udid: "00000000-0000-0000-0000-000000000015", os_type: "iOS", os_version: "17.0", state: "Booted", is_simulator: true)
        allow(Scan).to receive(:devices).and_return([simulator])

        expect(simulator).to receive(:boot)
        Scan::Runner.new.prelaunch_simulators
      end
    end

    # A Swift package, or a project that doesn't test on a simulator, has no simulators to act on
    describe "simulator options when scan picked no simulators" do
      def configure(options)
        allow(Scan).to receive(:config).and_return(FastlaneCore::Configuration.create(Scan::Options.available_options, options))
        allow(Scan).to receive(:devices).and_return(nil)
      end

      it "skips reinstalling the app" do
        configure(reinstall_app: true, app_identifier: "tools.fastlane.app")
        runner = Scan::Runner.new
        expect(runner).to receive(:execute)
        expect(FastlaneCore::Simulator).not_to receive(:uninstall_app)

        runner.test_app
      end

      it "skips collecting the simulator logs" do
        configure(include_simulator_logs: true)
        expect(FastlaneCore::Simulator).not_to receive(:copy_logs)

        Scan::Runner.new.copy_simulator_logs
      end
    end

    describe "test_results" do
      before(:each) do
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
          output_directory: '/tmp/scan_results',
          project: './scan/examples/standard/app.xcodeproj',
          include_simulator_logs: false
        })

        mock_slack_poster = Object.new
        allow(Scan::SlackPoster).to receive(:new).and_return(mock_slack_poster)
        allow(mock_slack_poster).to receive(:run)

        mock_test_command_generator = Object.new
        allow(Scan::TestCommandGenerator).to receive(:new).and_return(mock_test_command_generator)
        allow(mock_test_command_generator).to receive(:xcodebuild_log_path).and_return('./scan/spec/fixtures/boring.log')

        @scan = Scan::Runner.new
      end

      it "is deprecated" do
        Tempfile.create("junit_report") do |report|
          Scan.cache[:temp_junit_report] = report.path
          expect(FastlaneCore::UI).to receive(:deprecated).with(/Scan::Runner#test_results is deprecated/)
          @scan.test_results
        end
      end

      it "still proceeds successfully if the temp junit report was deleted", requires_xcodebuild: true do
        Scan.cache[:temp_junit_report] = '/var/folders/non_existent_file.junit'
        expect(@scan.test_results).to_not(be_nil)
        expect(Scan.cache[:temp_junit_report]).to_not(eq('/var/folders/non_existent_file.junit'))
      end

      describe "when output_style is raw" do
        it "still proceeds successfully and generates a temp junit report", requires_xcodebuild: true do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            output_directory: '/tmp/scan_results',
            project: './scan/examples/standard/app.xcodeproj',
            include_simulator_logs: false,
            output_style: "raw"
          })

          Scan.cache[:temp_junit_report] = '/var/folders/non_existent_file.junit'
          expect(@scan.test_results).to_not(be_nil)
          expect(Scan.cache[:temp_junit_report]).to_not(eq('/var/folders/non_existent_file.junit'))
        end
      end
    end

    describe "#open_report" do
      it "opens the report with its path as one argument" do
        report_path = "/Users/me/Kaldi's Kafe/fastlane/test_output/report.html"
        allow(FastlaneCore::Helper).to receive(:ci?).and_return(false)
        allow(Scan).to receive(:cache).and_return({ open_html_report_path: report_path })
        scan = Scan::Runner.new

        expect(scan).to receive(:system).with("open", "--hide", report_path)
        scan.open_report
      end
    end

    describe "#zip_build_products" do
      it "doesn't zip data when :should_zip_build_products is false", requires_xcodebuild: true do
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
          output_directory: '/tmp/scan_results',
          project: './scan/examples/standard/app.xcodeproj',
          should_zip_build_products: false
        })

        expect(FastlaneCore::CommandExecutor).not_to receive(:execute)

        scan = Scan::Runner.new
        scan.zip_build_products
      end

      it "zips data when :should_zip_build_products is true", requires_xcodebuild: true do
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
          output_directory: '/tmp/scan_results',
          derived_data_path: '/tmp/derived_data/app',
          project: './scan/examples/standard/app.xcodeproj',
          should_zip_build_products: true
        })

        path = File.join(Scan.config[:derived_data_path], "Build/Products")
        path = File.absolute_path(path)

        output_path = File.absolute_path('/tmp/scan_results/build_products.zip')

        expect(FastlaneCore::CommandExecutor).to receive(:execute)
          .with(hash_including(command: "cd #{path.shellescape} && rm -f #{output_path.shellescape} && zip -r #{output_path.shellescape} *", print_all: false))
          .exactly(1).times

        scan = Scan::Runner.new
        scan.zip_build_products
      end
    end

    describe "output_xctestrun" do
      it "copies .xctestrun file when :output_xctestrun is true", requires_xcodebuild: true do
        Dir.mktmpdir("scan_results") do |tmp_dir|
          # Configuration
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            derived_data_path: File.join(tmp_dir, 'derived_data'),
            output_directory: File.join(tmp_dir, 'output'),
            project: './scan/examples/standard/app.xcodeproj',
            output_xctestrun: true
          })

          # Make output directory
          FileUtils.mkdir_p(Scan.config[:output_directory])

          # Make derived data directory
          path = File.join(Scan.config[:derived_data_path], "Build/Products")
          FileUtils.mkdir_p(path)

          # Create .xctestrun file that will be copied
          xctestrun_path = File.join(path, 'something-project-something.xctestrun')
          FileUtils.touch(xctestrun_path)

          scan = Scan::Runner.new
          scan.copy_xctestrun

          output_path = File.join(Scan.config[:output_directory], 'settings.xctestrun')
          expect(File.file?(output_path)).to eq(true)
        end
      end
    end
  end
end
