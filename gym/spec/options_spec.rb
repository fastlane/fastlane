describe Gym do
  describe Gym::Options do
    it "raises an exception when project path wasn't found" do
      expect do
        options = { project: "./examples/standard/Example.xcodeproj", workspace: "./examples/cocoapods/Example.xcworkspace" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end.to raise_error "You can only pass either a 'project' or a 'workspace', not both"
    end

    it "raises an exception when skip_build_archive and skip_export are both specified" do
      expect do
        options = { workspace: "./examples/cocoapods/Example.xcworkspace", skip_build_archive: true, skip_export: true }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end.to raise_error "'skip_export' must be false to use 'skip_build_archive'"
    end

    it "removes the `ipa` from the output name if given" do
      options = { output_name: "Example.ipa", project: "./examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      expect(Gym.config[:output_name]).to eq("Example")
    end

    it "automatically chooses an existing scheme if the the defined one is not available" do
      options = { project: "./examples/standard/Example.xcodeproj", scheme: "NotHere" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      expect(Gym.config[:scheme]).to eq("Example")
    end

    it "replaces SEPARATOR (i.e. /) character with underscore(_) in output name" do
      options = { output_name: "feature" + File::SEPARATOR + "Example.ipa", project: "./examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      expect(Gym.config[:output_name]).to eq("feature_Example")
    end
  end
end
