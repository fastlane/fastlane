describe Snapshot do
  describe Snapshot::TestCommandGenerator do
    before do
      fake_out_xcode_project_loading
    end

    describe "Valid Configuration" do
      let(:options) { { project: "./example/Example.xcodeproj", scheme: "ExampleUITests" } }

      def configure(options)
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
      end
      context 'default options' do
        before do
          configure options
        end

        it "uses the default parameters" do
          expect(Dir).to receive(:mktmpdir).with("snapshot_derived").and_return("/tmp/path/to/snapshot_derived")
          command = Snapshot::TestCommandGenerator.generate(device_type: "Something")
          ios = command.join('').match(/OS=(\d+.\d+)/)[1]
          expect(command).to eq(
            [
              "set -o pipefail &&",
              "xcodebuild",
              "-scheme 'ExampleUITests'",
              "-project './example/Example.xcodeproj'",
              "-derivedDataPath '/tmp/path/to/snapshot_derived'",
              "-destination 'platform=iOS Simulator,id=,OS=#{ios}'",
              :build,
              :test,
              "| tee #{File.expand_path('~/Library/Logs/snapshot/Example-ExampleUITests.log')} | xcpretty "
            ])
        end
      end

      context 'fixed derivedDataPath' do
        before do
          configure options.merge(derived_data_path: 'fake/derived/path')
        end

        it 'uses the fixed derivedDataPath if given' do
          expect(Dir).not_to receive(:mktmpdir)
          command = Snapshot::TestCommandGenerator.generate(device_type: "Something")
          expect(command.join('')).to include("-derivedDataPath 'fake/derived/path'")
        end
      end
    end
  end
end
