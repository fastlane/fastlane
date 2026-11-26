describe Gym do
  # These examples read build settings. The suite only unsets option variables, so the global
  # lookup switch would still refuse them if the developer exported it
  around do |example|
    FastlaneSpec::Env.with_env_values("FASTLANE_DISALLOW_XCODEBUILD_SETTINGS_LOOKUP" => nil) { example.run }
  end

  before do
    fake_out_build_settings(GYM_BUILD_SETTINGS)
  end

  before(:all) do
    options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
    @config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
    @project = FastlaneCore::Project.new(@config)
  end

  describe "Project with multiple Schemes and Gymfile", requires_xcodebuild: true do
    before(:each) { Gym.config = @config }

    it "#schemes returns all available schemes" do
      expect(@project.schemes).to contain_exactly("Example", "ExampleTests")
    end

    it "executing `gym` will not ask for the scheme" do
      expect(Gym.config[:scheme]).to eq("Example")
    end
  end
end
