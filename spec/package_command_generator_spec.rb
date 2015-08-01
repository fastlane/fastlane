describe Gym do
  describe Gym::PackageCommandGenerator do
    it "works with the example project with no additional parameters" do
      Gym.config = {project: "./example/Example.xcodeproj"}

      result = Gym::PackageCommandGenerator.generate
      expect(result).to eq([
        "xcodebuild -exportArchive", 
        "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'", 
        "exportFormat ipa", 
        "-exportPath '#{Gym::PackageCommandGenerator.ipa_path}'", 
        ""
      ])
    end
  end
end