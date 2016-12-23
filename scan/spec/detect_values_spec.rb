describe Scan do
  describe Scan::DetectValues do
    before do
      options = { project: "./scan/examples/standard/app.xcodeproj" }
      Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      @project = FastlaneCore::Project.new(Scan.config)
    end

    it "fetches the path from the Xcode config" do
      derived_data = Scan.config[:derived_data_path]
      expect(derived_data).to match(%r{/.*Xcode/DerivedData/app-\w*$})
    end
  end
end
