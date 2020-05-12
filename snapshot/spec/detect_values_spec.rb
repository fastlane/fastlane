describe Snapshot do
  describe Snapshot::DetectValues do
    describe "value coercion" do
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
  end
end
