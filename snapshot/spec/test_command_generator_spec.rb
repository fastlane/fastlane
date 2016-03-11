describe Snapshot do
  describe Snapshot::TestCommandGenerator do
    describe "Valid Configuration" do
      before do
        options = { project: "./example/Example.xcodeproj", scheme: "ExampleUITests" }
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
      end

      it "uses the default parameters" do
        expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
        command = Snapshot::TestCommandGenerator.generate(device_type: "Something")
        ios = command.join('').match(/OS=(\d+.\d+)/)[1]
        expect(command).to eq([
                                "set -o pipefail &&",
                                "xcodebuild",
                                "-scheme 'ExampleUITests'",
                                "-project './example/Example.xcodeproj'",
                                "-derivedDataPath '/tmp/path/to/snapshot_derived'",
                                "-destination 'platform=iOS Simulator,id=,OS=#{ios}'",
                                :build,
                                :test,
                                "| tee '#{File.expand_path('~/Library/Logs/snapshot/Example-ExampleUITests.log')}' | xcpretty "
                              ])
      end
    end
  end
end
