describe Scan do
  describe Scan::DetectValues do
    before do
      options = { project: "./examples/standard/app.xcodeproj" }
      Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      @project = FastlaneCore::Project.new(Scan.config)

      # If this machine has never built this project (e.g. CI)
      # we still need the "Debug-iphonesimulator" directory
      # to generate the right testing command
      derived_data_path = @project.build_settings(key: "BUILT_PRODUCTS_DIR")
      FileUtils.mkdir_p(File.join(File.expand_path("..", derived_data_path), "Debug-iphonesimulator"))

      Scan.config = Scan.config # to trigger the derived_data detection again
    end

    it "fetches the path from the Xcode config" do
      derived_data = Scan.config[:derived_data_path]
      expect(derived_data).to match(%r{/.*Xcode/DerivedData/app-.*/Build/Products/Debug-iphonesimulator})
    end
  end
end
