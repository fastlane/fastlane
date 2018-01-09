describe Snapshot do
  describe Snapshot::TestCommandGeneratorXcode8 do
    let(:os_version) { "9.3" }
    let(:iphone6_9_3) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6", os_version: os_version, udid: "11111", state: "Don't Care", is_simulator: true) }
    let(:iphone6_9_3_2) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6s", os_version: os_version, udid: "22222", state: "Don't Care", is_simulator: true) }
    let(:iphone6_9_0) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6", os_version: '9.0', udid: "11111", state: "Don't Care", is_simulator: true) }
    let(:iphone6_9_2) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6", os_version: '9.2', udid: "11111", state: "Don't Care", is_simulator: true) }
    let(:iphone6_10_1) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6 (10.1)", os_version: '10.1', udid: "33333", state: "Don't Care", is_simulator: true) }
    let(:iphone6s_10_1) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6s (10.1)", os_version: '10.1', udid: "98765", state: "Don't Care", is_simulator: true) }
    let(:iphone4s_9_0) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 4s", os_version: '9.0', udid: "4444", state: "Don't Care", is_simulator: true) }
    let(:ipad_air_9_1) { FastlaneCore::DeviceManager::Device.new(name: "iPad Air", os_version: '9.1', udid: "12345", state: "Don't Care", is_simulator: true) }
    let(:appleTV) { FastlaneCore::DeviceManager::Device.new(name: "Apple TV 1080p", os_version: os_version, udid: "22222", state: "Don't Care", is_simulator: true) }

    before do
      allow(Snapshot::LatestOsVersion).to receive(:version).and_return(os_version)
      allow(FastlaneCore::DeviceManager).to receive(:simulators).and_return([iphone6_9_0, iphone6_9_3, iphone6_9_2, appleTV, iphone6_9_3_2, iphone6_10_1, iphone6s_10_1, iphone4s_9_0, ipad_air_9_1])
      fake_out_xcode_project_loading
    end

    describe '#destination' do
      it "returns the highest version available for device if no match for the specified/latest os_version" do
        allow(Snapshot).to receive(:config).and_return({ ios_version: os_version })
        device = "iPhone 4s"
        result = Snapshot::TestCommandGeneratorXcode8.destination(device)
        expect(result).to eq(["-destination 'platform=iOS Simulator,id=4444,OS=9.0'"])
      end
    end

    describe '#find_device' do
      it 'finds a device that has a matching name and OS version' do
        found = Snapshot::TestCommandGeneratorXcode8.find_device('iPhone 6', '9.0')
        expect(found).to eq(iphone6_9_0)
      end

      it 'does not find a device that has a different name' do
        found = Snapshot::TestCommandGeneratorXcode8.find_device('iPhone 5', '9.0')
        expect(found).to be(nil)
      end

      it 'finds a device with the same name, but a different OS version, picking the highest available OS version' do
        found = Snapshot::TestCommandGeneratorXcode8.find_device('iPhone 6', '10.0')
        expect(found).to be(iphone6_9_3)
      end
    end

    describe 'copy_simulator_logs' do
      before (:each) do
        @config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, {
          output_directory: '/tmp/scan_results',
          output_simulator_logs: true,
          devices: ['iPhone 6 (10.1)', 'iPhone 6s'],
          project: './snapshot/example/Example.xcodeproj',
          scheme: 'ExampleUITests',
          namespace_log_files: true
        })
      end

      it 'copies all device log archives to the output directory on macOS 10.12 (Siera)', requires_xcode: true do
        Snapshot.config = @config
        launcher_config = Snapshot::SimulatorLauncherConfiguration.new(snapshot_config: Snapshot.config)

        allow(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(command: "sw_vers -productVersion", print_all: false, print_command: false).
          and_return('10.12.1')

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(command: "xcrun simctl spawn 33333 log collect --output /tmp/scan_results/de-DE/system_logs-cfcd208495d565ef66e7dff9f98764da.logarchive 2>/dev/null", print_all: false, print_command: true)

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(command: "xcrun simctl spawn 98765 log collect --output /tmp/scan_results/en-US/system_logs-cfcd208495d565ef66e7dff9f98764da.logarchive 2>/dev/null", print_all: false, print_command: true)

        Snapshot::SimulatorLauncherXcode8.new(launcher_configuration: launcher_config).copy_simulator_logs(["iPhone 6 (10.1)"], "de-DE", nil, 0)
        Snapshot::SimulatorLauncherXcode8.new(launcher_configuration: launcher_config).copy_simulator_logs(["iPhone 6s (10.1)"], "en-US", nil, 0)
      end

      it 'copies all iOS 9 device log files to the output directory on macOS 10.12 (Sierra)', requires_xcode: true do
        Snapshot.config = @config
        launcher_config = Snapshot::SimulatorLauncherConfiguration.new(snapshot_config: Snapshot.config)

        allow(File).to receive(:exist?).with(/.*system\.log/).and_return(true)
        allow(FastlaneCore::CommandExecutor).to receive(:execute).with(command: "sw_vers -productVersion", print_all: false, print_command: false).and_return('10.12')

        expect(FileUtils).to receive(:rm_f).with(%r{#{Snapshot.config[:output_directory]}/de-DE/system-cfcd208495d565ef66e7dff9f98764da\.log}).and_return(true)
        expect(FileUtils).to receive(:cp).with(/.*/, %r{#{Snapshot.config[:output_directory]}/de-DE/system-cfcd208495d565ef66e7dff9f98764da\.log}).and_return(true)

        expect(FileUtils).to receive(:rm_f).with(%r{#{Snapshot.config[:output_directory]}/en-US/system-cfcd208495d565ef66e7dff9f98764da\.log}).and_return(true)
        expect(FileUtils).to receive(:cp).with(/.*/, %r{#{Snapshot.config[:output_directory]}/en-US/system-cfcd208495d565ef66e7dff9f98764da\.log}).and_return(true)

        Snapshot::SimulatorLauncherXcode8.new(launcher_configuration: launcher_config).copy_simulator_logs(["iPhone 6s"], "de-DE", nil, 0)
        Snapshot::SimulatorLauncherXcode8.new(launcher_configuration: launcher_config).copy_simulator_logs(["iPhone 6"], "en-US", nil, 0)
      end

      it 'copies all device log files to the output directory on macOS 10.11 (El Capitan)', requires_xcode: true do
        Snapshot.config = @config
        launcher_config = Snapshot::SimulatorLauncherConfiguration.new(snapshot_config: Snapshot.config)

        allow(File).to receive(:exist?).with(/.*system\.log/).and_return(true)
        allow(FastlaneCore::CommandExecutor).to receive(:execute).with(command: "sw_vers -productVersion", print_all: false, print_command: false).and_return('10.11.6')

        expect(FileUtils).to receive(:rm_f).with(%r{#{Snapshot.config[:output_directory]}/de-DE/system-cfcd208495d565ef66e7dff9f98764da\.log}).and_return(true)
        expect(FileUtils).to receive(:cp).with(/.*/, %r{#{Snapshot.config[:output_directory]}/de-DE/system-cfcd208495d565ef66e7dff9f98764da\.log}).and_return(true)

        expect(FileUtils).to receive(:rm_f).with(%r{#{Snapshot.config[:output_directory]}/en-US/system-cfcd208495d565ef66e7dff9f98764da\.log}).and_return(true)
        expect(FileUtils).to receive(:cp).with(/.*/, %r{#{Snapshot.config[:output_directory]}/en-US/system-cfcd208495d565ef66e7dff9f98764da\.log}).and_return(true)

        Snapshot::SimulatorLauncherXcode8.new(launcher_configuration: launcher_config).copy_simulator_logs(["iPhone 6s"], "de-DE", nil, 0)
        Snapshot::SimulatorLauncherXcode8.new(launcher_configuration: launcher_config).copy_simulator_logs(["iPad Air"], "en-US", nil, 0)
      end
    end

    describe "Valid iOS Configuration" do
      let(:options) { { project: "./snapshot/example/Example.xcodeproj", scheme: "ExampleUITests", namespace_log_files: true } }

      def configure(options)
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
      end

      context 'default options' do
        it "uses the default parameters", requires_xcode: true do
          configure(options)
          expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
          command = Snapshot::TestCommandGeneratorXcode8.generate(device_type: "iPhone 6", language: "en", locale: nil)
          id = command.join('').match(/id=(.+?),/)[1]
          ios = command.join('').match(/OS=(\d+.\d+)/)[1]
          expect(command).to eq(
            [
              "set -o pipefail &&",
              "xcodebuild",
              "-scheme ExampleUITests",
              "-project ./snapshot/example/Example.xcodeproj",
              "-derivedDataPath '/tmp/path/to/snapshot_derived'",
              "-destination 'platform=iOS Simulator,id=#{id},OS=#{ios}'",
              "FASTLANE_SNAPSHOT=YES",
              :build,
              :test,
              "| tee #{File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/Example-ExampleUITests-iPhone\\ 6-en.log")} | xcpretty "
            ]
          )
        end

        it "allows to supply custom xcargs", requires_xcode: true do
          configure(options.merge(xcargs: "-only-testing:TestBundle/TestSuite/Screenshots"))
          expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
          command = Snapshot::TestCommandGeneratorXcode8.generate(device_type: "iPhone 6", language: "en", locale: nil)
          id = command.join('').match(/id=(.+?),/)[1]
          ios = command.join('').match(/OS=(\d+.\d+)/)[1]
          expect(command).to eq(
            [
              "set -o pipefail &&",
              "xcodebuild",
              "-scheme ExampleUITests",
              "-project ./snapshot/example/Example.xcodeproj",
              "-derivedDataPath '/tmp/path/to/snapshot_derived'",
              "-only-testing:TestBundle/TestSuite/Screenshots",
              "-destination 'platform=iOS Simulator,id=#{id},OS=#{ios}'",
              "FASTLANE_SNAPSHOT=YES",
              :build,
              :test,
              "| tee #{File.expand_path('~/Library/Logs/snapshot/Example-ExampleUITests-iPhone\\ 6-en.log')} | xcpretty "
            ]
          )
        end

        it "uses the default parameters on tvOS too", requires_xcode: true do
          configure(options.merge(devices: ["Apple TV 1080p"]))
          expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
          command = Snapshot::TestCommandGeneratorXcode8.generate(device_type: "Apple TV 1080p", language: "en", locale: nil)
          id = command.join('').match(/id=(.+?),/)[1]
          os = command.join('').match(/OS=(\d+.\d+)/)[1]
          expect(command).to eq(
            [
              "set -o pipefail &&",
              "xcodebuild",
              "-scheme ExampleUITests",
              "-project ./snapshot/example/Example.xcodeproj",
              "-derivedDataPath '/tmp/path/to/snapshot_derived'",
              "-destination 'platform=tvOS Simulator,id=#{id},OS=#{os}'",
              "FASTLANE_SNAPSHOT=YES",
              :build,
              :test,
              "| tee #{File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/Example-ExampleUITests-Apple\\ TV\\ 1080p-en.log")} | xcpretty "
            ]
          )
        end
      end

      context 'fixed derivedDataPath' do
        before do
          configure(options.merge(derived_data_path: 'fake/derived/path'))
        end

        it 'uses the fixed derivedDataPath if given', requires_xcode: true do
          expect(Dir).not_to(receive(:mktmpdir))
          command = Snapshot::TestCommandGeneratorXcode8.generate(device_type: "iPhone 6", language: "en", locale: nil)
          expect(command.join('')).to include("-derivedDataPath 'fake/derived/path'")
        end
      end
    end

    describe "Valid macOS Configuration" do
      let(:options) { { project: "./snapshot/example/Example.xcodeproj", scheme: "ExampleMacOS", namespace_log_files: true } }

      it "uses default parameters on macOS", requires_xcode: true do
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options.merge(devices: ["Mac"]))
        expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
        command = Snapshot::TestCommandGeneratorXcode8.generate(device_type: "Mac", language: "en", locale: nil)
        expect(command).to eq(
          [
            "set -o pipefail &&",
            "xcodebuild",
            "-scheme ExampleMacOS",
            "-project ./snapshot/example/Example.xcodeproj",
            "-derivedDataPath '/tmp/path/to/snapshot_derived'",
            "-destination 'platform=macOS'",
            "FASTLANE_SNAPSHOT=YES",
            :build,
            :test,
            "| tee #{File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/ExampleMacOS-ExampleMacOS-Mac-en.log")} | xcpretty "
          ]
        )
      end
    end

    describe "Unique logs" do
      let(:options) { { project: "./snapshot/example/Example.xcodeproj", scheme: "ExampleUITests", namespace_log_files: true } }

      it 'uses correct name and language', requires_xcode: true do
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
        log_path = Snapshot::TestCommandGeneratorXcode8.xcodebuild_log_path(device_type: "iPhone 6", language: "pt", locale: nil)
        expect(log_path).to eq(
          File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/Example-ExampleUITests-iPhone 6-pt.log").to_s
        )
      end

      it 'uses includes locale if specified', requires_xcode: true do
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
        log_path = Snapshot::TestCommandGeneratorXcode8.xcodebuild_log_path(device_type: "iPhone 6", language: "pt", locale: "pt_BR")
        expect(log_path).to eq(
          File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/Example-ExampleUITests-iPhone 6-pt-pt_BR.log").to_s
        )
      end

      it 'can work without parameters', requires_xcode: true do
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
        log_path = Snapshot::TestCommandGeneratorXcode8.xcodebuild_log_path
        expect(log_path).to eq(
          File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/Example-ExampleUITests.log").to_s
        )
      end
    end

    describe "Unique logs disabled" do
      let(:options) { { project: "./snapshot/example/Example.xcodeproj", scheme: "ExampleUITests" } }

      it 'uses correct file name', requires_xcode: true do
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
        log_path = Snapshot::TestCommandGeneratorXcode8.xcodebuild_log_path(device_type: "iPhone 6", language: "pt", locale: nil)
        expect(log_path).to eq(
          File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/Example-ExampleUITests.log").to_s
        )
      end
    end
  end
end
