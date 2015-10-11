describe Snapshot do
  describe Snapshot::TestCommandGenerator do
    describe "Valid Configuration" do
      before do
        options = { project: "./example/Example.xcodeproj", scheme: "ExampleUITests" }
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
      end

      it "uses the default parameters" do
        command = Snapshot::TestCommandGenerator.generate(device_type: "Something")
        expect(command).to eq([
          "set -o pipefail &&", 
          "xcodebuild", 
          "-scheme 'ExampleUITests'", 
          "-project './example/Example.xcodeproj'", 
          "-derivedDataPath '/tmp/snapshot_derived/'", 
          "-destination 'platform=iOS Simulator,id=,OS=9.0'", 
          :test, 
          "| tee '/Users/fkrause/Library/Logs/snapshot/Example-ExampleUITests.log' | xcpretty"
        ])
      end
    end
  end
end
