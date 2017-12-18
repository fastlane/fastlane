describe Gym do
  before(:all) do
    options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
    @config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
    @project = FastlaneCore::Project.new(@config)
  end

  describe "Project with multiple Schemes and Gymfile", requires_xcodebuild: true do
    before(:each) { Gym.config = @config }

    it "#schemes returns all available schemes" do
      expect(@project.schemes).to eq(["Example", "ExampleTests"])
    end

    it "executing `gym` will not ask for the scheme" do
      expect(Gym.config[:scheme]).to eq("Example")
    end
  end
end
