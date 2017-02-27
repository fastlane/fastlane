describe Gym do
  before(:all) do
    options = { project: "./gym/examples/standard/Example.xcodeproj" }
    config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
    @project = FastlaneCore::Project.new(config)
  end
  before(:each) do
    allow(Gym).to receive(:project).and_return(@project)
  end

  describe Gym::PackageCommandGeneratorLegacy do
    it "works with the example project with no additional parameters" do
      options = { project: "./gym/examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::PackageCommandGeneratorLegacy.generate
      expect(result).to eq([
                             "/usr/bin/xcrun /tmp/PackageApplication4Gym -v",
                             "''",
                             "-o '#{Gym::PackageCommandGeneratorLegacy.ipa_path}'",
                             "exportFormat ipa",
                             ""
                           ])
    end

    it "works with the example project with no additional parameters and an apostrophe/single quote in the product name" do
      options = { project: "./gym/examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      allow(Gym::PackageCommandGeneratorLegacy).to receive(:appfile_path).and_return("Krause's App")

      result = Gym::PackageCommandGeneratorLegacy.generate
      expect(result).to eq([
                             "/usr/bin/xcrun /tmp/PackageApplication4Gym -v",
                             "Krause\\'s\\ App",
                             "-o '#{Gym::PackageCommandGeneratorLegacy.ipa_path}'",
                             "exportFormat ipa",
                             ""
                           ])
    end

    it "works with spaces in path name" do
      options = { project: "./gym/examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      allow(Gym::XcodebuildFixes).to receive(:patch_package_application).and_return("/tmp/path with spaces")

      result = Gym::PackageCommandGeneratorLegacy.generate
      expect(result).to eq([
                             "/usr/bin/xcrun /tmp/path\\ with\\ spaces -v",
                             "''",
                             "-o '#{Gym::PackageCommandGeneratorLegacy.ipa_path}'",
                             "exportFormat ipa",
                             ""
                           ])
    end

    it "supports passing a path to a provisioning profile" do
      # Profile Installation
      expect(FastlaneCore::ProvisioningProfile).to receive(:install).with("./gym/spec/fixtures/dummy.mobileprovision")
      options = {
        project: "./gym/examples/standard/Example.xcodeproj",
        provisioning_profile_path: "./gym/spec/fixtures/dummy.mobileprovision"
      }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::PackageCommandGeneratorLegacy.generate
      expect(result).to eq([
                             "/usr/bin/xcrun /tmp/PackageApplication4Gym -v",
                             "''",
                             "-o '#{Gym::PackageCommandGeneratorLegacy.ipa_path}'",
                             "exportFormat ipa",
                             "--embed './gym/spec/fixtures/dummy.mobileprovision'",
                             ""
                           ])
    end

    it "uses a temporary folder to store the resulting ipa file" do
      options = { project: "./gym/examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::PackageCommandGeneratorLegacy.generate
      expect(Gym::PackageCommandGeneratorLegacy.temporary_output_path).to match(%r{#{Dir.tmpdir}/gym_output.+})
      expect(Gym::PackageCommandGeneratorLegacy.ipa_path).to match(%r{#{Dir.tmpdir}/gym_output.+/ExampleProductName.ipa})
    end
  end
end
