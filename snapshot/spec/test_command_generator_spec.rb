describe Snapshot do
  describe Snapshot::TestCommandGenerator do
    let(:os_version) { "9.3" }
    let(:iphone6_9_3) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6", os_version: os_version, udid: "11111", state: "Don't Care", is_simulator: true) }
    let(:iphone6_9_3_2) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6s", os_version: os_version, udid: "22222", state: "Don't Care", is_simulator: true) }
    let(:iphone6_9_0) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6", os_version: '9.0', udid: "11111", state: "Don't Care", is_simulator: true) }
    let(:iphone6_9_2) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 6", os_version: '9.2', udid: "11111", state: "Don't Care", is_simulator: true) }
    let(:appleTV) { FastlaneCore::DeviceManager::Device.new(name: "Apple TV 1080p", os_version: os_version, udid: "22222", state: "Don't Care", is_simulator: true) }

    before do
      allow(Snapshot::LatestOsVersion).to receive(:version).and_return(os_version)
      allow(FastlaneCore::DeviceManager).to receive(:simulators).and_return([iphone6_9_0, iphone6_9_3, iphone6_9_2, appleTV, iphone6_9_3_2])
      fake_out_xcode_project_loading
    end

    describe '#find_device' do
      it 'finds a device that has a matching name and OS version' do
        found = Snapshot::TestCommandGenerator.find_device('iPhone 6', '9.0')
        expect(found).to eq(iphone6_9_0)
      end

      it 'does not find a device that has a different name' do
        found = Snapshot::TestCommandGenerator.find_device('iPhone 5', '9.0')
        expect(found).to be(nil)
      end

      it 'finds a device with the same name, but a different OS version, picking the highest available OS version' do
        found = Snapshot::TestCommandGenerator.find_device('iPhone 6', '10.0')
        expect(found).to be(iphone6_9_3)
      end
    end

    describe 'output_simulator_logs' do
      it 'copies all device logs to the output directory' do
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, {
          output_directory: '/tmp/scan_results',
          output_simulator_logs: true,
          devices: ['iPhone 6', 'iPhone 6s'],
          project: './snapshot/example/Example.xcodeproj',
          scheme: 'ExampleUITests'
        })
        expect(FileUtils).to receive(:cp_r).with(/.*/, %r{de-DE/system_logs-cfcd208495d565ef66e7dff9f98764da.logarchive}).and_return(true)
        expect(FileUtils).to receive(:cp_r).with(/.*/, %r{en-US/system_logs-cfcd208495d565ef66e7dff9f98764da.logarchive}).and_return(true)

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(command: "xcrun simctl getenv 11111 SIMULATOR_SHARED_RESOURCES_DIRECTORY 2>/dev/null", print_all: false, print_command: true).
          and_return("/tmp/folder")

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(command: "xcrun simctl spawn 11111 log collect 2>/dev/null", print_all: false, print_command: true).
          and_return("/tmp/folder")

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(command: "xcrun simctl getenv 22222 SIMULATOR_SHARED_RESOURCES_DIRECTORY 2>/dev/null", print_all: false, print_command: true).
          and_return("/tmp/folder")

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(command: "xcrun simctl spawn 22222 log collect 2>/dev/null", print_all: false, print_command: true).
          and_return("/tmp/folder")

        Snapshot::Runner.new.output_simulator_logs("iPhone 6s", "de-DE", nil, 0)
        Snapshot::Runner.new.output_simulator_logs("iPhone 6", "en-US", nil, 0)
      end
    end

    describe "Valid Configuration" do
      let(:options) { { project: "./snapshot/example/Example.xcodeproj", scheme: "ExampleUITests" } }

      def configure(options)
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
      end

      context 'default options' do
        it "uses the default parameters" do
          configure options
          expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
          command = Snapshot::TestCommandGenerator.generate(device_type: "iPhone 6")
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
              "| tee #{File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/Example-ExampleUITests.log")} | xcpretty "
            ]
          )
        end

        it "allows to supply custom xcargs" do
          configure options.merge(xcargs: "-only-testing:TestBundle/TestSuite/Screenshots")
          expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
          command = Snapshot::TestCommandGenerator.generate(device_type: "iPhone 6")
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
              "| tee #{File.expand_path('~/Library/Logs/snapshot/Example-ExampleUITests.log')} | xcpretty "
            ]
          )
        end

        it "uses the default parameters on tvOS too" do
          configure options.merge(devices: ["Apple TV 1080p"])
          expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
          command = Snapshot::TestCommandGenerator.generate(device_type: "Apple TV 1080p")
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
              "| tee #{File.expand_path("#{FastlaneCore::Helper.buildlog_path}/snapshot/Example-ExampleUITests.log")} | xcpretty "
            ]
          )
        end
      end

      context 'fixed derivedDataPath' do
        before do
          configure options.merge(derived_data_path: 'fake/derived/path')
        end

        it 'uses the fixed derivedDataPath if given' do
          expect(Dir).not_to receive(:mktmpdir)
          command = Snapshot::TestCommandGenerator.generate(device_type: "iPhone 6")
          expect(command.join('')).to include("-derivedDataPath 'fake/derived/path'")
        end
      end
    end
  end
end
