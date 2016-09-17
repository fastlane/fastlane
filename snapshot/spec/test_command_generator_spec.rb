describe Snapshot do
  describe Snapshot::TestCommandGenerator do
    before do
      mock_os_version = "6.6"
      allow(Snapshot::LatestOsVersion).to receive(:version).and_return(mock_os_version)
      allow(FastlaneCore::DeviceManager).to receive(:simulators).and_return(
        [
          FastlaneCore::DeviceManager::Device.new(name: "iPhone 6", os_version: mock_os_version, udid: "11111", state: "Don't Care", is_simulator: true),
          FastlaneCore::DeviceManager::Device.new(name: "Apple TV 1080p", os_version: mock_os_version, udid: "22222", state: "Don't Care", is_simulator: true)
        ]
      )
      fake_out_xcode_project_loading
    end

    describe "Valid Configuration" do
      let(:options) { { project: "./example/Example.xcodeproj", scheme: "ExampleUITests" } }

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
              "-project ./example/Example.xcodeproj",
              "-derivedDataPath '/tmp/path/to/snapshot_derived'",
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
              "-project ./example/Example.xcodeproj",
              "-derivedDataPath '/tmp/path/to/snapshot_derived'",
              "-destination 'platform=tvOS Simulator,id=#{id},OS=#{os}'",
              "FASTLANE_SNAPSHOT=YES",
              :build,
              :test,
              "| tee #{File.expand_path('~/Library/Logs/snapshot/Example-ExampleUITests.log')} | xcpretty "
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
