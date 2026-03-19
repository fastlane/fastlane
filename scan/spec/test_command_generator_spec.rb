describe Scan do
  before(:all) do
    options = { project: "./scan/examples/standard/app.xcodeproj" }
    config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
    @project = FastlaneCore::Project.new(config)
  end

  before(:each) do
    FastlaneCore::Simulator.clear_cache
    devices_json = File.read("./scan/spec/fixtures/SimctlJsonDevices")
    runtimes_json = File.read("./scan/spec/fixtures/SimctlJsonRuntimes")
    status = double('status', "success?": true)
    allow(Open3).to receive(:capture2).with('xcrun simctl list -j devices').and_return([devices_json, status])
    allow(Open3).to receive(:capture2).with('xcrun simctl list -j runtimes').and_return([runtimes_json, status])

    allow(Open3).to receive(:capture3).with("xcrun simctl runtime -h").and_return([nil, 'Usage: simctl runtime <operation> <arguments>', nil])

    allow(FastlaneCore::Helper).to receive(:xcode_at_least?).and_return(false)
    allow(FastlaneCore::CommandExecutor).to receive(:execute).with(command: "sw_vers -productVersion", print_all: false, print_command: false).and_return('10.12.1')

    allow(Scan).to receive(:project).and_return(@project)
  end

  context "with xcpretty" do
    before(:each) do
      allow(Fastlane::Helper::XcodebuildFormatterHelper).to receive(:xcbeautify_installed?).and_return(false)
    end

    describe Scan::TestCommandGenerator do
      before(:each) do
        @test_command_generator = Scan::TestCommandGenerator.new
        @project.options.delete(:use_system_scm)
      end

      it "raises an exception when project path wasn't found" do
        tmp_path = Dir.mktmpdir
        path = "#{tmp_path}/notExistent"
        expect do
          options = { project: path }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end.to raise_error("Project file not found at path '#{path}'")
      end

      describe "Supports toolchain" do
        it "should fail if :xctestrun and :toolchain is set" do
          allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(".")
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              scan(
                project: './scan/examples/standard/app.xcodeproj',
                xctestrun: './path/1.xctestrun',
                toolchain: 'com.apple.dt.toolchain.Swift_2_3'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'toolchain' and 'xctestrun'")
        end

        it "passes the toolchain option to xcodebuild", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj", sdk: "9.0", toolchain: "com.apple.dt.toolchain.Swift_2_3" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-sdk '9.0'",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-toolchain 'com.apple.dt.toolchain.Swift_2_3'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         :build,
                                         :test
                                       ])
        end
      end

      it "supports additional parameters", requires_xcodebuild: true do
        log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

        xcargs = { DEBUG: "1", BUNDLE_NAME: "Example App" }
        options = { project: "./scan/examples/standard/app.xcodeproj", sdk: "9.0", xcargs: xcargs }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = @test_command_generator.generate

        expect(result).to start_with([
                                       "set -o pipefail &&",
                                       "env NSUnbufferedIO=YES xcodebuild",
                                       "-scheme app",
                                       "-project ./scan/examples/standard/app.xcodeproj",
                                       "-sdk '9.0'",
                                       "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                       "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                       "DEBUG=1 BUNDLE_NAME=Example\\ App",
                                       :build,
                                       :test
                                     ])
      end

      describe "supports number of retries" do
        before(:each) do
          allow(FastlaneCore::Helper).to receive(:xcode_at_least?).and_return(true)
        end

        it "with 1 or more retries", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", sdk: "9.0", number_of_retries: 1 }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-sdk '9.0'",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         "-retry-tests-on-failure",
                                         "-test-iterations 2",
                                         :build,
                                         :test
                                       ])
        end
      end

      it "supports custom xcpretty formatter as a gem name", requires_xcodebuild: true do
        options = { formatter: "custom-formatter", project: "./scan/examples/standard/app.xcodeproj", sdk: "9.0" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = @test_command_generator.generate
        expect(result.last).to include("| xcpretty -f `custom-formatter`")
      end

      it "supports custom xcpretty formatter as a path to a ruby file", requires_xcodebuild: true do
        options = { formatter: "custom-formatter.rb", project: "./scan/examples/standard/app.xcodeproj", sdk: "9.0" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = @test_command_generator.generate
        expect(result.last).to include("| xcpretty -f 'custom-formatter.rb'")
      end

      it "uses system scm", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", use_system_scm: true }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        result = @test_command_generator.generate
        expect(result).to include("-scmProvider system").once
      end

      it "uses system scm via project options", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj" }
        @project.options[:use_system_scm] = true
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        result = @test_command_generator.generate
        expect(result).to include("-scmProvider system").once
      end

      it "uses system scm options exactly once", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", use_system_scm: true }
        @project.options[:use_system_scm] = true
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        result = @test_command_generator.generate
        expect(result).to include("-scmProvider system").once
      end

      it "defaults to Xcode scm when option is not provided", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        result = @test_command_generator.generate
        expect(result).to_not(include("-scmProvider system"))
      end

      describe "Standard Example" do
        describe "Xcode project" do
          before do
            options = { project: "./scan/examples/standard/app.xcodeproj" }
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          end

          it "uses the correct build command with the example project with no additional parameters", requires_xcodebuild: true do
            log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

            result = @test_command_generator.generate
            expect(result).to start_with([
                                           "set -o pipefail &&",
                                           "env NSUnbufferedIO=YES xcodebuild",
                                           "-scheme app",
                                           "-project ./scan/examples/standard/app.xcodeproj",
                                           "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                           "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                           :build,
                                           :test
                                         ])
          end

          it "#project_path_array", requires_xcodebuild: true do
            result = @test_command_generator.project_path_array
            expect(result).to eq(["-scheme app", "-project ./scan/examples/standard/app.xcodeproj"])
          end

          it "#build_path", requires_xcodebuild: true do
            result = @test_command_generator.build_path
            regex = %r{Library/Developer/Xcode/Archives/\d\d\d\d\-\d\d\-\d\d}
            expect(result).to match(regex)
          end

          it "#buildlog_path is used when provided", requires_xcodebuild: true do
            options = { project: "./scan/examples/standard/app.xcodeproj", buildlog_path: "/tmp/my/path" }
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
            result = @test_command_generator.xcodebuild_log_path
            expect(result).to include("/tmp/my/path")
          end

          it "#buildlog_path is not used when not provided", requires_xcodebuild: true do
            result = @test_command_generator.xcodebuild_log_path
            expect(result.to_s).to include(File.expand_path("#{FastlaneCore::Helper.buildlog_path}/scan"))
          end
        end

        describe "SPM package" do
          describe "No workspace" do
            before do
              options = { package_path: "./scan/examples/package/", scheme: "package" }
              Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
            end

            it "uses the correct build command with the example package and scheme", requires_xcodebuild: true do
              log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

              result = @test_command_generator.generate
              expect(result).to start_with([
                                             "set -o pipefail &&",
                                             "cd ./scan/examples/package/ &&",
                                             "env NSUnbufferedIO=YES xcodebuild",
                                             "-scheme package",
                                             "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                             "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                             :build,
                                             :test
                                           ])
            end

            it "#project_path_array", requires_xcodebuild: true do
              result = @test_command_generator.project_path_array
              expect(result).to eq(["-scheme package"])
            end
          end

          describe "With workspace" do
            before do
              options = { package_path: "./scan/examples/package/", scheme: "package", workspace: "." }
              Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
            end

            it "uses the correct build command with the example package and scheme", requires_xcodebuild: true do
              log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

              result = @test_command_generator.generate
              expect(result).to start_with([
                                             "set -o pipefail &&",
                                             "cd ./scan/examples/package/ &&",
                                             "env NSUnbufferedIO=YES xcodebuild",
                                             "-scheme package",
                                             "-workspace .",
                                             "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                             "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                             :build,
                                             :test
                                           ])
            end

            it "#project_path_array", requires_xcodebuild: true do
              result = @test_command_generator.project_path_array
              expect(result).to eq(["-scheme package", "-workspace ."])
            end
          end
        end
      end

      describe "Derived Data Example" do
        before do
          options = { project: "./scan/examples/standard/app.xcodeproj", derived_data_path: "/tmp/my/derived_data" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end

        it "uses the correct build command with the example project", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath /tmp/my/derived_data",
                                         :build,
                                         :test
                                       ])
        end
      end

      describe "Test Parallel Testing" do
        # don't want to override settings defined in xcode unless explicitly asked to
        it "doesn't add option if not passed explicitly", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).not_to include("-parallel-testing-enabled YES") if FastlaneCore::Helper.xcode_at_least?(10)
          expect(result).not_to include("-parallel-testing-enabled NO") if FastlaneCore::Helper.xcode_at_least?(10)
        end

        it "specify YES when set to true", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", parallel_testing: true }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to include("-parallel-testing-enabled YES") if FastlaneCore::Helper.xcode_at_least?(10)
        end

        it "specify NO when set to false", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", parallel_testing: false }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to include("-parallel-testing-enabled NO") if FastlaneCore::Helper.xcode_at_least?(10)
        end
      end

      describe "Test Concurrent Workers" do
        before do
          options = { project: "./scan/examples/standard/app.xcodeproj", concurrent_workers: 4 }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end

        it "uses the correct number of concurrent workers", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          result = @test_command_generator.generate
          expect(result).to include("-parallel-testing-worker-count 4") if FastlaneCore::Helper.xcode_at_least?(10)
        end
      end

      describe "Test Max Concurrent Simulators" do
        before do
          options = { project: "./scan/examples/standard/app.xcodeproj", max_concurrent_simulators: 3 }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end

        it "uses the correct number of concurrent simulators", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          result = @test_command_generator.generate
          expect(result).to include("-maximum-concurrent-test-simulator-destinations 3") if FastlaneCore::Helper.xcode_at_least?(10)
        end
      end

      describe "Test Disable Concurrent Simulators" do
        before do
          options = { project: "./scan/examples/standard/app.xcodeproj", disable_concurrent_testing: true }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end

        it "disables concurrent simulators", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          result = @test_command_generator.generate
          expect(result).to include("-disable-concurrent-testing") if FastlaneCore::Helper.xcode_at_least?(10)
        end
      end

      describe "with Scan option :include_simulator_logs" do
        context "extract system.logarchive" do
          it "copies all device logs to the output directory", requires_xcodebuild: true do
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
              output_directory: '/tmp/scan_results',
              include_simulator_logs: true,
              devices: ["iPhone 6s", "iPad Air"],
              project: './scan/examples/standard/app.xcodeproj'
            })
            Scan.cache[:temp_junit_report] = './scan/spec/fixtures/boring.log'

            # This is a needed side effect from running TestCommandGenerator which is not done in this test
            Scan.cache[:result_bundle_path] = '/tmp/scan_results/test.xcresults'

            expect(FastlaneCore::CommandExecutor).
              to receive(:execute).
              with(command: %r{xcrun simctl spawn 021A465B-A294-4D9E-AD07-6BDC8E186343 log collect --start '\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d' --output /tmp/scan_results/system_logs-iPhone\\ 6s_iOS_10.0.logarchive 2>/dev/null}, print_all: false, print_command: true)

            expect(FastlaneCore::CommandExecutor).
              to receive(:execute).
              with(command: %r{xcrun simctl spawn 2ABEAF08-E480-4617-894F-6BAB587E7963 log collect --start '\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d' --output /tmp/scan_results/system_logs-iPad\\ Air_iOS_10.0.logarchive 2>/dev/null}, print_all: false, print_command: true)

            allow(Trainer::TestParser).to receive(:auto_convert).and_return({
              "some/path": {
                successful: true,
                number_of_tests: 100,
                number_of_failures: 0,
                number_of_tests_excluding_retries: 10,
                number_of_failures_excluding_retries: 0,
                number_of_retries: 0
              }
            })

            mock_test_result_parser = Object.new
            allow(Scan::TestResultParser).to receive(:new).and_return(mock_test_result_parser)
            allow(mock_test_result_parser).to receive(:parse_result).and_return({ tests: 100, failures: 0 })

            mock_slack_poster = Object.new
            allow(Scan::SlackPoster).to receive(:new).and_return(mock_slack_poster)
            allow(mock_slack_poster).to receive(:run)

            mock_test_command_generator = Object.new
            allow(Scan::TestCommandGenerator).to receive(:new).and_return(mock_test_command_generator)
            allow(mock_test_command_generator).to receive(:xcodebuild_log_path).and_return('./scan/spec/fixtures/boring.log')

            Scan::Runner.new.handle_results(0)
          end
        end
      end

      describe "Result Bundle Example" do
        it "uses the correct build command with the example project when using Xcode 10 or earlier", requires_xcodebuild: true do
          allow(FastlaneCore::Helper).to receive(:xcode_version).and_return('10')
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", result_bundle: true, scheme: 'app' }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         "-resultBundlePath ./fastlane/test_output/app.test_result",
                                         :build,
                                         :test
                                       ])
        end

        it "uses the correct build command with the example project when using Xcode 11 or later", requires_xcodebuild: true do
          allow(FastlaneCore::Helper).to receive(:xcode_version).and_return('11')
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", result_bundle: true, scheme: 'app' }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         "-resultBundlePath ./fastlane/test_output/app.xcresult",
                                         :build,
                                         :test
                                       ])
        end

        it "uses the correct build command with the example project when using Xcode 11 or later and a custom result bundle path", requires_xcodebuild: true do
          allow(FastlaneCore::Helper).to receive(:xcode_version).and_return('11')
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", result_bundle_path: "./my_test_output/Alice's Man$ion backtick` quote\" 2024-09-30 at 5.10.35 PM (1).xcresult", scheme: 'app' }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         "-resultBundlePath ./my_test_output/Alice\\'s\\ Man\\$ion\\ backtick\\`\\ quote\\\"\\ 2024-09-30\\ at\\ 5.10.35\\ PM\\ \\(1\\).xcresult",
                                         :build,
                                         :test
                                       ])
        end
      end

      describe "Test Exclusion Example" do
        it "only tests the test bundle/suite/cases specified in only_testing when the input is an array", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", scheme: 'app',
                      only_testing: %w(TestBundleA/TestSuiteB TestBundleC) }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         '-only-testing:TestBundleA/TestSuiteB',
                                         '-only-testing:TestBundleC',
                                         :build,
                                         :test
                                       ])
        end

        it "only tests the test bundle/suite/cases specified in only_testing when the input is a string", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", scheme: 'app',
                      only_testing: 'TestBundleA/TestSuiteB' }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         '-only-testing:TestBundleA/TestSuiteB',
                                         :build,
                                         :test
                                       ])
        end

        it "does not the test bundle/suite/cases specified in skip_testing when the input is an array", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", scheme: 'app',
                      skip_testing: %w(TestBundleA/TestSuiteB TestBundleC) }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         '-skip-testing:TestBundleA/TestSuiteB',
                                         '-skip-testing:TestBundleC',
                                         :build,
                                         :test
                                       ])
        end

        it "does not the test bundle/suite/cases specified in skip_testing when the input is a string", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          options = { project: "./scan/examples/standard/app.xcodeproj", scheme: 'app',
                      skip_testing: 'TestBundleA/TestSuiteB' }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         '-skip-testing:TestBundleA/TestSuiteB',
                                         :build,
                                         :test
                                       ])
        end
      end

      it "uses a device without version specifier", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", device: "iPhone 6s" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = @test_command_generator.generate
        expect(result).to start_with([
                                       "set -o pipefail &&",
                                       "env NSUnbufferedIO=YES xcodebuild",
                                       "-scheme app",
                                       "-project ./scan/examples/standard/app.xcodeproj",
                                       # expect the single highest versioned iOS simulator device available with matching name
                                       "-destination 'platform=iOS Simulator,id=021A465B-A294-4D9E-AD07-6BDC8E186343'",
                                       "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                       :build,
                                       :test
                                     ])
      end

      it "uses multiple devices", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", devices: [
          "iPhone 6s (9.3)",
          "iPad Air (9.3)"
        ] }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = @test_command_generator.generate
        expect(result).to start_with([
                                       "set -o pipefail &&",
                                       "env NSUnbufferedIO=YES xcodebuild",
                                       "-scheme app",
                                       "-project ./scan/examples/standard/app.xcodeproj",
                                       "-destination 'platform=iOS Simulator,id=70E1E92F-A292-4980-BC3C-7770C5EEFCFD' " \
                                       "-destination 'platform=iOS Simulator,id=DD134998-177F-47DA-99FA-D549D9305476'",
                                       "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                       :build,
                                       :test
                                     ])
      end

      it "rejects devices with versions below deployment target", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", device: "iPhone 5 (8.4)" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = @test_command_generator.generate
        # FIXME: expect UI error starting "No simulators found that are equal to the version of specifier"
      end

      describe "test-without-building and build-for-testing" do
        before do
          options = { project: "./scan/examples/standard/app.xcodeproj", destination: [
            "platform=iOS Simulator,name=iPhone 6s,OS=9.3",
            "platform=iOS Simulator,name=iPad Air 2,OS=9.2"
          ] }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end

        it "should build-for-testing", requires_xcodebuild: true do
          Scan.config[:build_for_testing] = true

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' " \
                                         "-destination 'platform=iOS Simulator,name=iPad Air 2,OS=9.2'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         "build-for-testing"
                                       ])
        end
        it "should test-without-building", requires_xcodebuild: true do
          Scan.config[:test_without_building] = true

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' " \
                                         "-destination 'platform=iOS Simulator,name=iPad Air 2,OS=9.2'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         "test-without-building"
                                       ])
        end
        it "should raise an exception if two build_modes are set", requires_xcodebuild: true do
          allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(".")
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              scan(
                project: './scan/examples/standard/app.xcodeproj',
                test_without_building: true,
                build_for_testing: true
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'test_without_building' and 'build_for_testing'")
        end

        it "should run tests from xctestrun file", requires_xcodebuild: true do
          Scan.config[:xctestrun] = "/folder/mytests.xctestrun"

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' " \
                                         "-destination 'platform=iOS Simulator,name=iPad Air 2,OS=9.2'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         "-xctestrun '/folder/mytests.xctestrun'",
                                         "test-without-building"
                                       ])
        end
      end

      describe "Multiple devices example" do
        it "uses multiple destinations", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj", destination: [
            "platform=iOS Simulator,name=iPhone 6s,OS=9.3",
            "platform=iOS Simulator,name=iPad Air 2,OS=9.2"
          ] }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' " \
                                         "-destination 'platform=iOS Simulator,name=iPad Air 2,OS=9.2'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         :build,
                                         :test
                                       ])
        end

        it "uses multiple devices", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj", devices: [
            "iPhone 6s (9.3)",
            "iPad Air (9.3)"
          ] }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=70E1E92F-A292-4980-BC3C-7770C5EEFCFD' " \
                                         "-destination 'platform=iOS Simulator,id=DD134998-177F-47DA-99FA-D549D9305476'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         :build,
                                         :test
                                       ])
        end

        it "de-duplicates devices matching same simulator", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj", devices: [
            "iPhone 5 (9.0)",
            "iPhone 5 (9.0.0)"
          ] }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj",
                                         "-destination 'platform=iOS Simulator,id=9905A018-9DC9-4DD8-BA14-B0B000CC8622'",
                                         "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                         :build,
                                         :test
                                       ])
        end

        it "raises an error if multiple devices are specified for `device`" do
          expect do
            options = { project: "./scan/examples/standard/app.xcodeproj", device: [
              "iPhone 6s (9.3)",
              "iPad Air (9.3)"
            ] }
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          end.to raise_error("'device' value must be a String! Found Array instead.")
        end

        it "raises an error if both `device` and `devices` were given" do
          expect do
            options = {
              project: "./scan/examples/standard/app.xcodeproj",
              device: ["iPhone 6s (9.3)"],
              devices: ["iPhone 6"]
            }
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          end.to raise_error("'device' value must be a String! Found Array instead.")
        end
      end

      describe "Custom xcodebuild_command example" do
        it "uses xcodebuild_command", requires_xcodebuild: true do
          options = {
            project: "./scan/examples/standard/app.xcodeproj",
            xcodebuild_command: "env NSUnbufferedIO=YES /usr/local/bin/build-wrapper-macosx-x86 --out-dir ./build/bw_output xcodebuild"
          }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result).to start_with([
                                         "set -o pipefail &&",
                                         "env NSUnbufferedIO=YES /usr/local/bin/build-wrapper-macosx-x86 --out-dir ./build/bw_output xcodebuild",
                                         "-scheme app",
                                         "-project ./scan/examples/standard/app.xcodeproj"
                                       ])
        end
      end

      describe "Specifying a test plan" do
        before do
          options = { project: "./scan/examples/standard/app.xcodeproj", testplan: "simple" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end

        it "adds the testplan to the xcodebuild command", requires_xcodebuild: true do
          log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

          result = @test_command_generator.generate
          expect(result).to include("-testPlan simple") if FastlaneCore::Helper.xcode_at_least?(11)
        end
      end

      describe "Test plan configuration example" do
        it "only tests the test configuration specified in only_test_configurations when the input is an array", requires_xcodebuild: true do
          options = {
            project: "./scan/examples/standard/app.xcodeproj",
            testplan: "simple",
            only_test_configurations: %w(TestConfigurationA TestConfigurationB)
          }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          if FastlaneCore::Helper.xcode_at_least?(11)
            expect(result).to start_with([
                                           "set -o pipefail &&",
                                           "env NSUnbufferedIO=YES xcodebuild",
                                           "-scheme app",
                                           "-project ./scan/examples/standard/app.xcodeproj",
                                           "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                           "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                           "-testPlan 'simple'",
                                           "-only-test-configuration 'TestConfigurationA'",
                                           "-only-test-configuration 'TestConfigurationB'",
                                           :build,
                                           :test
                                         ])
          end
        end

        it "only tests the test configuration specified in only_test_configurations when the input is a string", requires_xcodebuild: true do
          options = {
            project: "./scan/examples/standard/app.xcodeproj",
            testplan: "simple",
            only_test_configurations: 'TestConfigurationA'
          }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          if FastlaneCore::Helper.xcode_at_least?(11)
            expect(result).to start_with([
                                           "set -o pipefail &&",
                                           "env NSUnbufferedIO=YES xcodebuild",
                                           "-scheme app",
                                           "-project ./scan/examples/standard/app.xcodeproj",
                                           "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                           "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                           "-testPlan 'simple'",
                                           "-only-test-configuration 'TestConfigurationA'",
                                           :build,
                                           :test
                                         ])
          end
        end

        it "does not test the test configuration specified in skip_test_configurations when the input is an array", requires_xcodebuild: true do
          options = {
            project: "./scan/examples/standard/app.xcodeproj",
            testplan: "simple",
            skip_test_configurations: %w(TestConfigurationA TestConfigurationB)
          }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          if FastlaneCore::Helper.xcode_at_least?(11)
            expect(result).to start_with([
                                           "set -o pipefail &&",
                                           "env NSUnbufferedIO=YES xcodebuild",
                                           "-scheme app",
                                           "-project ./scan/examples/standard/app.xcodeproj",
                                           "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                           "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                           "-testPlan 'simple'",
                                           "-skip-test-configuration 'TestConfigurationA'",
                                           "-skip-test-configuration 'TestConfigurationB'",
                                           :build,
                                           :test
                                         ])
          end
        end

        it "does not test the test configuration specified in skip_test_configurations when the input is a string", requires_xcodebuild: true do
          options = {
            project: "./scan/examples/standard/app.xcodeproj",
            testplan: "simple",
            skip_test_configurations: "TestConfigurationA"
          }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate

          if FastlaneCore::Helper.xcode_at_least?(11)
            expect(result).to start_with([
                                           "set -o pipefail &&",
                                           "env NSUnbufferedIO=YES xcodebuild",
                                           "-scheme app",
                                           "-project ./scan/examples/standard/app.xcodeproj",
                                           "-destination 'platform=iOS Simulator,id=E697990C-3A83-4C01-83D1-C367011B31EE'",
                                           "-derivedDataPath #{Scan.config[:derived_data_path].shellescape}",
                                           "-testPlan 'simple'",
                                           "-skip-test-configuration 'TestConfigurationA'",
                                           :build,
                                           :test
                                         ])
          end
        end
      end

      context "disable_xcpretty" do
        it "does not include xcpretty in the pipe command when true", requires_xcode: true do
          options = { disable_xcpretty: true, project: "./scan/examples/standard/app.xcodeproj", sdk: "9.0" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result.last).to_not(include("| xcpretty "))
        end

        it "includes xcpretty in the pipe command when false", requires_xcode: true do
          options = { disable_xcpretty: false, project: "./scan/examples/standard/app.xcodeproj", sdk: "9.0" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          result = @test_command_generator.generate
          expect(result.last).to include("| xcpretty ")
        end
      end
    end
  end

  context "with any formatter" do
    let(:log_path) { "log_path" }

    before(:each) do
      @test_command_generator = Scan::TestCommandGenerator.new
      @project.options.delete(:use_system_scm)

      allow(@test_command_generator).to receive(:xcodebuild_log_path).and_return(log_path)
    end

    describe "#pipe" do
      it "uses no pipe with disable_xcpretty", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", disable_xcpretty: true }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        pipe = @test_command_generator.pipe

        expect(pipe).to eq(["| tee '#{log_path}'"])
      end

      it "uses no pipe with output_type of raw", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", disable_xcpretty: true }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        pipe = @test_command_generator.pipe

        expect(pipe).to eq(["| tee '#{log_path}'"])
      end

      describe "with xcodebuild_formatter" do
        describe "with no xcpretty options" do
          it "default when xcbeautify not installed", requires_xcodebuild: true do
            allow(Fastlane::Helper::XcodebuildFormatterHelper).to receive(:xcbeautify_installed?).and_return(false)

            options = { project: "./scan/examples/standard/app.xcodeproj" }
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

            pipe = @test_command_generator.pipe

            expect(pipe.join(" ")).to include("| xcpretty ")
          end

          it "default when xcbeautify installed", requires_xcodebuild: true do
            allow(Fastlane::Helper::XcodebuildFormatterHelper).to receive(:xcbeautify_installed?).and_return(true)

            options = { project: "./scan/examples/standard/app.xcodeproj" }
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

            pipe = @test_command_generator.pipe

            expect(pipe).to eq(["| tee '#{log_path}'", "| xcbeautify"])
          end

          it "xcpretty override when xcbeautify installed", requires_xcodebuild: true do
            allow(Fastlane::Helper::XcodebuildFormatterHelper).to receive(:xcbeautify_installed?).and_return(true)

            options = { project: "./scan/examples/standard/app.xcodeproj", xcodebuild_formatter: "xcpretty" }
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

            pipe = @test_command_generator.pipe

            expect(pipe.join(" ")).to include("| xcpretty ")
          end

          it "customer formatter", requires_xcodebuild: true do
            allow(Fastlane::Helper::XcodebuildFormatterHelper).to receive(:xcbeautify_installed?).and_return(true)

            options = { project: "./scan/examples/standard/app.xcodeproj", xcodebuild_formatter: "/path/to/another/xcbeautify" }
            Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

            pipe = @test_command_generator.pipe

            expect(pipe).to eq(["| tee '#{log_path}'", "| /path/to/another/xcbeautify"])
          end
        end

        it "with xcpretty options when xcbeautify installed", requires_xcodebuild: true do
          allow(Fastlane::Helper::XcodebuildFormatterHelper).to receive(:xcbeautify_installed?).and_return(true)

          options = { project: "./scan/examples/standard/app.xcodeproj", output_style: "rspec" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

          pipe = @test_command_generator.pipe

          expect(pipe.join(" ")).to include("| xcpretty ")
        end
      end
    end

    describe "#legacy_xcpretty_options" do
      it "with formatter", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", formatter: "Something.rb" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        options = @test_command_generator.legacy_xcpretty_options
        expect(options).to eq(['formatter'])
      end

      it "with xcpretty_formatter", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", xcpretty_formatter: "Something.rb" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        options = @test_command_generator.legacy_xcpretty_options
        expect(options).to eq(['xcpretty_formatter'])
      end

      it "with output_style", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", output_style: "rspec" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        options = @test_command_generator.legacy_xcpretty_options
        expect(options).to eq(['output_style'])
      end

      it "with output_types of 'json-compilation-database'", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", output_types: 'json-compilation-database' }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        options = @test_command_generator.legacy_xcpretty_options
        expect(options).to eq(['output_types'])
      end

      it "with customer_report_file_name", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj", custom_report_file_name: 'some_file.html', output_types: 'html' }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        options = @test_command_generator.legacy_xcpretty_options
        expect(options).to eq(['custom_report_file_name'])
      end
    end
  end
end
