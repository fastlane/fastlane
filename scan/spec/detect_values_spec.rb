describe Scan do
  describe Scan::DetectValues do
    describe 'Xcode project' do
      describe 'detects FastlaneCore::Project' do
        it 'with no :project or :package_path given', requires_xcodebuild: true do
          # Mocks input from detect_projects
          project = FastlaneCore::Project.new({
            project: "./scan/examples/standard/app.xcodeproj"
          })

          expect(FastlaneCore::Project).to receive(:detect_projects)
          expect(FastlaneCore::Project).to receive(:new).and_return(project)

          options = {}
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end

        it 'with :project given', requires_xcodebuild: true do
          expect(FastlaneCore::Project).to receive(:detect_projects)
          expect(FastlaneCore::Project).to receive(:new).and_call_original

          options = { project: "./scan/examples/standard/app.xcodeproj" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end
      end
    end

    describe 'SPM package' do
      describe 'does not attempt to detect FastlaneCore::Project' do
        it 'with :package_path given', requires_xcodebuild: true do
          expect(FastlaneCore::Project).to_not(receive(:detect_projects))

          options = { package_path: "./scan/examples/package/" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end
      end
    end

    describe 'Xcode config handling' do
      before do
        options = { project: "./scan/examples/standard/app.xcodeproj" }
        FileUtils.mkdir_p("./scan/examples/standard/app.xcodeproj/project.xcworkspace/xcuserdata/#{ENV['USER']}.xcuserdatad/")
        FileUtils.copy("./scan/examples/standard/WorkspaceSettings.xcsettings", "./scan/examples/standard/app.xcodeproj/project.xcworkspace/xcuserdata/#{ENV['USER']}.xcuserdatad/WorkspaceSettings.xcsettings")
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        @project = FastlaneCore::Project.new(Scan.config)
      end

      it "fetches the path from the Xcode config", requires_xcodebuild: true do
        derived_data = Scan.config[:derived_data_path]
        expect(derived_data).to match(File.expand_path("./scan/examples/standard/"))
      end
    end

    describe "#detect_sdk_version" do
      it 'informs users of unknown platform name' do
        expect do
          Scan::DetectValues.detect_sdk_version('test')
        end.to raise_error(FastlaneCore::Interface::FastlaneCrash, "Unknown platform: test")
      end
      %w[iOS tvOS watchOS].each do |platform|
        simulator_name = Scan::DetectValues::PLATFORM_SIMULATOR_NAME[platform]

        it "returns an error if there is no default #{platform} SDK symlink" do
          default_path = double("path/to/default.sdk")
          platform_path = double("path/to/sdks")
          sdks_path = double("full/path/to/sdks",
                             children: [
                               double("path/to/other.sdk", symlink?: false),
                               double("path/to/some.sdk",  symlink?: false),
                               double("path/to/default.sdk", symlink?: false)
                             ])

          allow(Pathname).to receive(:new).with("Platforms/#{simulator_name}.platform/Developer/SDKs/").and_return(platform_path)
          allow(FastlaneCore::Helper).to receive(:xcode_path).and_return('mock')
          allow(Pathname).to receive(:new).with('mock').and_return(sdks_path)
          allow(sdks_path).to receive(:join).with(platform_path).and_return(sdks_path)
          allow(sdks_path).to receive(:join).with("#{simulator_name}.sdk").and_return(default_path)

          expect do
            Scan::DetectValues.detect_sdk_version(platform)
          end.to raise_error(FastlaneCore::Interface::FastlaneCrash, "Unable to find default #{simulator_name} SDK version from SDKs: #{sdks_path.children}")
        end

        it "returns an error on failure to determine #{platform} SDK version from filename" do
          default_path = double("path/to/default.sdk")
          platform_path = double("path/to/sdks")
          some_path = double("path/to/some.sdk", symlink?: true, realpath: default_path, basename: "#{simulator_name}.sdk")
          sdks_path = double("full/path/to/sdks",
                             children: [
                               double("path/to/other.sdk", symlink?: false),
                               some_path,
                               double("path/to/default.sdk", symlink?: false)
                             ])

          allow(Pathname).to receive(:new).with("Platforms/#{simulator_name}.platform/Developer/SDKs/").and_return(platform_path)
          allow(FastlaneCore::Helper).to receive(:xcode_path).and_return('mock')
          allow(Pathname).to receive(:new).with('mock').and_return(sdks_path)
          allow(sdks_path).to receive(:join).with(platform_path).and_return(sdks_path)
          allow(sdks_path).to receive(:join).with("#{simulator_name}.sdk").and_return(default_path)

          expect do
            Scan::DetectValues.detect_sdk_version(platform)
          end.to raise_error(FastlaneCore::Interface::FastlaneCrash, "Could not determine SDK version from #{some_path}")
        end

        it "returns an error on failure to parse #{platform} SDK version from filename" do
          default_path = double("path/to/default.sdk")
          platform_path = double("path/to/sdks")
          some_path = double("path/to/some.sdk", symlink?: true, realpath: default_path, basename: "#{simulator_name}asdf17g.sdk")
          sdks_path = double("full/path/to/sdks",
                             children: [
                               double("path/to/other.sdk", symlink?: false),
                               some_path,
                               double("path/to/default.sdk", symlink?: false)
                             ])

          allow(Pathname).to receive(:new).with("Platforms/#{simulator_name}.platform/Developer/SDKs/").and_return(platform_path)
          allow(FastlaneCore::Helper).to receive(:xcode_path).and_return('mock')
          allow(Pathname).to receive(:new).with('mock').and_return(sdks_path)
          allow(sdks_path).to receive(:join).with(platform_path).and_return(sdks_path)
          allow(sdks_path).to receive(:join).with("#{simulator_name}.sdk").and_return(default_path)

          expect do
            Scan::DetectValues.detect_sdk_version(platform)
          end.to raise_error(FastlaneCore::Interface::FastlaneCrash, "Could not parse SDK version: Malformed version number string asdf17g")
        end

        it "detects the expected default for #{platform}" do
          default_path = double("path/to/default.sdk")
          platform_path = double("path/to/sdks")
          target_version = "17.0"
          sdks_path = double("full/path/to/sdks",
                             children: [
                               double("path/to/other.sdk", symlink?: false),
                               double("path/to/some.sdk",  symlink?: true, realpath: default_path, basename: "#{simulator_name}#{target_version}.sdk"),
                               double("path/to/default.sdk", symlink?: false)
                             ])

          allow(Pathname).to receive(:new).with("Platforms/#{simulator_name}.platform/Developer/SDKs/").and_return(platform_path)
          allow(FastlaneCore::Helper).to receive(:xcode_path).and_return('mock')
          allow(Pathname).to receive(:new).with('mock').and_return(sdks_path)
          allow(sdks_path).to receive(:join).with(platform_path).and_return(sdks_path)
          allow(sdks_path).to receive(:join).with("#{simulator_name}.sdk").and_return(default_path)

          expect(Scan::DetectValues.detect_sdk_version(platform.to_s)).to equal(Gem::Version.new(target_version))
        end
      end
    end

    describe "#detect_simulator" do
      it 'returns simulators for requested devices', requires_xcodebuild: true do
        simctl_device_output = double("simctl device output", read: File.read('./scan/spec/fixtures/DeviceManagerSimctlOutputXcode15'))
        expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, simctl_device_output, nil, nil)

        simctl_runtime_output = double("simctl runtime output", read: "line\n")
        allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, simctl_runtime_output, nil, nil)

        allow(Scan::DetectValues).to receive(:detect_sdk_version).with('iOS').and_return(Gem::Version.new('17.0'))
        allow(Scan::DetectValues).to receive(:detect_sdk_version).with('tvOS').and_return(Gem::Version.new('17.0'))
        allow(Scan::DetectValues).to receive(:detect_sdk_version).with('watchOS').and_return(Gem::Version.new('10.0'))

        devices = ['iPhone 14 Pro Max', 'Apple TV 4K (3rd generation)', 'Apple Watch Ultra (49mm)']
        simulators = Scan::DetectValues.detect_simulator(devices, '', '', '', nil)

        expect(simulators.count).to eq(3)
        expect(simulators[0]).to have_attributes(
          name: "iPhone 14 Pro Max", os_type: "iOS", os_version: "17.0"
        )
        expect(simulators[1]).to have_attributes(
          name: "Apple TV 4K (3rd generation)", os_type: "tvOS", os_version: "17.0"
        )
        expect(simulators[2]).to have_attributes(
          name: "Apple Watch Ultra (49mm)", os_type: "watchOS", os_version: "10.0"
        )
      end

      it 'filters out simulators newer than what the current Xcode SDK supports', requires_xcodebuild: true do
        simctl_device_output = double("simctl device output", read: File.read('./scan/spec/fixtures/DeviceManagerSimctlOutputXcode14'))
        expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, simctl_device_output, nil, nil)

        simctl_runtime_output = double("simctl runtime output", read: "line\n")
        allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, simctl_runtime_output, nil, nil)

        allow(Scan::DetectValues).to receive(:detect_sdk_version).with('iOS').and_return(Gem::Version.new('16.4'))
        allow(Scan::DetectValues).to receive(:detect_sdk_version).with('tvOS').and_return(Gem::Version.new('16.4'))
        allow(Scan::DetectValues).to receive(:detect_sdk_version).with('watchOS').and_return(Gem::Version.new('9.4'))

        devices = ['iPhone 14 Pro Max', 'iPad Pro (12.9-inch) (6th generation) (16.1)', 'Apple TV 4K (3rd generation)', 'Apple Watch Ultra (49mm)']
        simulators = Scan::DetectValues.detect_simulator(devices, '', '', '', nil)

        expect(simulators.count).to eq(4)
        expect(simulators[0]).to have_attributes(
          name: "iPhone 14 Pro Max", os_type: "iOS", os_version: "16.4"
        )
        expect(simulators[1]).to have_attributes(
          name: "iPad Pro (12.9-inch) (6th generation)", os_type: "iOS", os_version: "16.1"
        )
        expect(simulators[2]).to have_attributes(
          name: "Apple TV 4K (3rd generation)", os_type: "tvOS", os_version: "16.4"
        )
        expect(simulators[3]).to have_attributes(
          name: "Apple Watch Ultra (49mm)", os_type: "watchOS", os_version: "9.4"
        )
      end
    end

    describe "#detect_destination" do
      it "ios", requires_xcodebuild: true do
        options = { project: "./scan/examples/standard/app.xcodeproj" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Scan.config[:destination].first).to match(/platform=iOS/)
      end

      context "catalyst" do
        it "ios", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj" }
          expect_any_instance_of(FastlaneCore::Project).to receive(:supports_mac_catalyst?).and_return(true)
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          expect(Scan.config[:destination].first).to match(/platform=iOS/)
        end

        it "mac", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj", catalyst_platform: "macos" }
          expect_any_instance_of(FastlaneCore::Project).to receive(:supports_mac_catalyst?).and_return(true)
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          expect(Scan.config[:destination].first).to match(/platform=macOS,variant=Mac Catalyst/)
        end
      end

      context ":run_rosetta_simulator" do
        it "adds arch=x86_64 if true", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj", run_rosetta_simulator: true }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          expect(Scan.config[:destination].first).to match(/platform=iOS/)
          expect(Scan.config[:destination].first).to match(/,arch=x86_64/)
        end

        it "does not add arch=x86_64 if false", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj", run_rosetta_simulator: false }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          expect(Scan.config[:destination].first).to match(/platform=iOS/)
          expect(Scan.config[:destination].first).to_not(match(/,arch=x86_64/))
        end

        it "does not add arch=x86_64 by default", requires_xcodebuild: true do
          options = { project: "./scan/examples/standard/app.xcodeproj" }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          expect(Scan.config[:destination].first).to match(/platform=iOS/)
          expect(Scan.config[:destination].first).to_not(match(/,arch=x86_64/))
        end
      end
    end

    describe "validation" do
      before(:each) do
        allow(Fastlane::Helper::XcodebuildFormatterHelper).to receive(:xcbeautify_installed?).and_return(false)
      end

      it "advises of problems with multiple output_types and a custom_report_file_name", requires_xcodebuild: true do
        options = {
          project: "./scan/examples/standard/app.xcodeproj",
          # use default output types
          custom_report_file_name: 'report.xml'
        }
        expect(FastlaneCore::UI).to receive(:user_error!).with("Using a :custom_report_file_name with multiple :output_types (html,junit) will lead to unexpected results. Use :output_files instead.")
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      end

      it "does not advise of a problem with one output_type and a custom_report_file_name", requires_xcodebuild: true do
        options = {
          project: "./scan/examples/standard/app.xcodeproj",
          output_types: 'junit',
          custom_report_file_name: 'report.xml'
        }
        expect(FastlaneCore::UI).not_to(receive(:user_error!))
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      end
    end

    describe "value coercion" do
      it "coerces only_testing to be an array", requires_xcodebuild: true do
        options = {
          project: "./scan/examples/standard/app.xcodeproj",
          only_testing: "Bundle/SuiteA"
        }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Scan.config[:only_testing]).to eq(["Bundle/SuiteA"])
      end

      it "coerces skip_testing to be an array", requires_xcodebuild: true do
        options = {
          project: "./scan/examples/standard/app.xcodeproj",
          skip_testing: "Bundle/SuiteA,Bundle/SuiteB"
        }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Scan.config[:skip_testing]).to eq(["Bundle/SuiteA", "Bundle/SuiteB"])
      end

      it "leaves skip_testing as an array", requires_xcodebuild: true do
        options = {
          project: "./scan/examples/standard/app.xcodeproj",
          skip_testing: ["Bundle/SuiteA", "Bundle/SuiteB"]
        }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Scan.config[:skip_testing]).to eq(["Bundle/SuiteA", "Bundle/SuiteB"])
      end

      it "coerces only_test_configurations to be an array", requires_xcodebuild: true do
        options = {
          project: "./scan/examples/standard/app.xcodeproj",
          only_test_configurations: "ConfigurationA"
        }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Scan.config[:only_test_configurations]).to eq(["ConfigurationA"])
      end

      it "coerces skip_test_configurations to be an array", requires_xcodebuild: true do
        options = {
          project: "./scan/examples/standard/app.xcodeproj",
          skip_test_configurations: "ConfigurationA,ConfigurationB"
        }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Scan.config[:skip_test_configurations]).to eq(["ConfigurationA", "ConfigurationB"])
      end

      it "leaves skip_test_configurations as an array", requires_xcodebuild: true do
        options = {
          project: "./scan/examples/standard/app.xcodeproj",
          skip_test_configurations: ["ConfigurationA", "ConfigurationB"]
        }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Scan.config[:skip_test_configurations]).to eq(["ConfigurationA", "ConfigurationB"])
      end
    end
  end
end
