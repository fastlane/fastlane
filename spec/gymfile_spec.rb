describe Gym do
  describe "Project with multiple Schemes and Gymfile" do
    before do
      options = { project: "./examples/multipleSchemes/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options,
                                                      options)
      @project = Gym::Project.new(Gym.config)
    end

    it "#schemes returns all available schemes" do
      expect(@project.schemes).to eq(["Example", "ExampleTests"])
    end

    it "executing `gym` will not ask for the scheme" do
      expect(Gym.config[:scheme]).to eq("Example")
    end
  end
end
