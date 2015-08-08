describe Gym do
  describe Gym::Options do
    it "raises an exception when project path wasn't found" do
      expect do
        options = { project: "./example/standard/Example.xcodeproj", workspace: "./example/cocoapods/Example.xcworkspace" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end.to raise_error "You can only pass either a workspace or a project path, not both".red
    end

    it "removes the `ipa` from the output name if given" do
      options = { output_name: "Example.ipa", project: "./example/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      expect(Gym.config[:output_name]).to eq("Example")
    end
  end
end
