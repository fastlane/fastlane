describe Snapshot do
  describe Snapshot::DetectValues do
    describe "value coercion" do
      it "coerces only_testing to be an array", requires_xcodebuild: true do
        options = {
          project: "./snapshot/examples/standard/app.xcodeproj",
          only_testing: "Bundle/SuiteA"
        }
        Snapshot.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Snapshot.config[:only_testing]).to eq(["Bundle/SuiteA"])
      end

      it "leave only_testing as an array", requires_xcodebuild: true do
        options = {
          project: "./snapshot/examples/standard/app.xcodeproj",
          only_testing: ["Bundle/SuiteA", "Bundle/SuiteB"]
        }
        Snapshot.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Snapshot.config[:only_testing]).to eq(["Bundle/SuiteA", "Bundle/SuiteB"])
      end

      it "coerces skip_testing to be an array", requires_xcodebuild: true do
        options = {
          project: "./snapshot/examples/standard/app.xcodeproj",
          skip_testing: "Bundle/SuiteA,Bundle/SuiteB"
        }
        Snapshot.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Snapshot.config[:skip_testing]).to eq(["Bundle/SuiteA", "Bundle/SuiteB"])
      end

      it "leaves skip_testing as an array", requires_xcodebuild: true do
        options = {
          project: "./snapshot/examples/standard/app.xcodeproj",
          skip_testing: ["Bundle/SuiteA", "Bundle/SuiteB"]
        }
        Snapshot.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        expect(Snapshot.config[:skip_testing]).to eq(["Bundle/SuiteA", "Bundle/SuiteB"])
      end
    end
  end
end
