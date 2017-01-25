describe Scan do
  describe Scan::DetectValues do
    before do
      options = {
        project: "./scan/examples/standard/app.xcodeproj",
        only_testing: "Bundle/SuiteA",
        skip_testing: "Bundle/SuiteB"
      }
      Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      @project = FastlaneCore::Project.new(Scan.config)
    end

    it "fetches the path from the Xcode config" do
      derived_data = Scan.config[:derived_data_path]
      expect(derived_data).to match(%r{/.*Xcode/DerivedData/app-\w*$})
    end

    it "coerces only_testing to be an array" do
      expect(Scan.config[:only_testing]).to eq(["Bundle/SuiteA"])
    end

    it "coerces skip_testing to be an array" do
      expect(Scan.config[:skip_testing]).to eq(["Bundle/SuiteB"])
    end
  end
end
