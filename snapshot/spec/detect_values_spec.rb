describe Snapshot do
  describe Snapshot::DetectValues do
    describe "value coercion" do
      before(:each) do
        allow(Snapshot).to receive(:snapfile_name).and_return("some fake snapfile")
      end

      it "coerces only_testing to be an array", requires_xcodebuild: true do
        options = {
            project: "./snapshot/example/Example.xcodeproj",
            scheme: "ExampleUITests",
            only_testing: "Bundle/SuiteA"
        }
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
        expect(Snapshot.config[:only_testing]).to eq(["Bundle/SuiteA"])
      end

      it "coerces skip_testing to be an array", requires_xcodebuild: true do
        options = {
            project: "./snapshot/example/Example.xcodeproj",
            scheme: "ExampleUITests",
            skip_testing: "Bundle/SuiteA,Bundle/SuiteB"
        }
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
        expect(Snapshot.config[:skip_testing]).to eq(["Bundle/SuiteA", "Bundle/SuiteB"])
      end

      it "leaves skip_testing as an array", requires_xcodebuild: true do
        options = {
            project: "./snapshot/example/Example.xcodeproj",
            scheme: "ExampleUITests",
            skip_testing: ["Bundle/SuiteA", "Bundle/SuiteB"]
        }
        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
        expect(Snapshot.config[:skip_testing]).to eq(["Bundle/SuiteA", "Bundle/SuiteB"])
      end
    end

    describe "device configuration for Mac projects" do
      before(:each) do
        allow(Snapshot).to receive(:snapfile_name).and_return("some fake snapfile")
        fake_out_xcode_project_loading
        allow(File).to receive(:expand_path).and_call_original
        allow(File).to receive(:expand_path).with("some fake snapfile").and_return("/fake/path/Snapfile")
        allow(File).to receive(:expand_path).with("..", "./snapshot/example/Example.xcodeproj").and_return("./snapshot/example")
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with("./snapshot/example/Example.xcodeproj").and_return(true)
        allow(File).to receive(:exist?).with("/fake/path/Snapfile").and_return(false)
        allow(File).to receive(:exist?).with("./snapshot/example/some fake snapfile").and_return(false)
        allow(Dir).to receive(:chdir).and_yield
      end

      it "sets devices to ['Mac'] when devices is nil and project is Mac", requires_xcodebuild: true do
        options = {
            project: "./snapshot/example/Example.xcodeproj",
            scheme: "ExampleMacOSUITests"
        }
        mock_project = instance_double(FastlaneCore::Project, mac?: true, path: "./snapshot/example/Example.xcodeproj", select_scheme: nil)
        allow(FastlaneCore::Project).to receive(:new).and_return(mock_project)
        allow(FastlaneCore::Project).to receive(:detect_projects)

        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)

        expect(Snapshot.config[:devices]).to eq(["Mac"])
      end

      it "does not overwrite devices when devices is already set and project is Mac", requires_xcodebuild: true do
        # Get a real device name from available simulators to avoid validation errors
        available_devices = FastlaneCore::Simulator.all.map(&:name)
        test_device = available_devices.first || "iPhone 16 Pro Max"

        options = {
            project: "./snapshot/example/Example.xcodeproj",
            scheme: "ExampleMacOSUITests",
            devices: [test_device]
        }
        mock_project = instance_double(FastlaneCore::Project, mac?: true, path: "./snapshot/example/Example.xcodeproj", select_scheme: nil)
        allow(FastlaneCore::Project).to receive(:new).and_return(mock_project)
        allow(FastlaneCore::Project).to receive(:detect_projects)

        Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)

        expect(Snapshot.config[:devices]).to eq([test_device])
      end
    end
  end
end
