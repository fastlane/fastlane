describe Gym do
  describe Gym::Options do
    it "raises an exception when project path wasn't found" do
      expect do
        options = { project: "./gym/examples/standard/Example.xcodeproj", workspace: "./gym/examples/cocoapods/Example.xcworkspace" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end.to raise_error "You can only pass either a 'project' or a 'workspace', not both"
    end

    it "raises an exception when Xcode >= 8.3 and use_legacy_build_api is used" do
      expect do
        options = { workspace: "./gym/examples/cocoapods/Example.xcworkspace", use_legacy_build_api: true }
        expect(Gym::Xcode).to receive(:legacy_api_deprecated?).and_return(true)
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end.to raise_error "legacy_build_api removed!"
    end

    it "legacy api still works on old xcode < 8.3" do
      expect do
        options = { scheme: "Example", workspace: "./gym/examples/cocoapods/Example.xcworkspace", use_legacy_build_api: true }
        expect(Gym::Xcode).to receive(:legacy_api_deprecated?).and_return(false)
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end.to_not raise_error
    end

    it "removes the `ipa` from the output name if given" do
      options = { output_name: "Example.ipa", project: "./gym/examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      expect(Gym.config[:output_name]).to eq("Example")
    end

    it "automatically chooses an existing scheme if the the defined one is not available" do
      options = { project: "./gym/examples/standard/Example.xcodeproj", scheme: "NotHere" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      expect(Gym.config[:scheme]).to eq("Example")
    end

    it "replaces SEPARATOR (i.e. /) character with underscore(_) in output name" do
      options = { output_name: "feature" + File::SEPARATOR + "Example.ipa", project: "./gym/examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      expect(Gym.config[:output_name]).to eq("feature_Example")
    end
  end
end
