describe Gym do
  describe Gym::Project do
    it "raises an exception if path was not found" do
      expect do
        Gym::Project.new(project: "/tmp/notHere123")
      end.to raise_error "Could not find project at path '/tmp/notHere123'".red
    end

    describe "Valid Standard Project" do
      before do
        options = { project: "./examples/standard/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        @project = Gym::Project.new(Gym.config)
      end

      it "#path" do
        expect(@project.path).to eq(File.expand_path("./examples/standard/Example.xcodeproj"))
      end

      it "#is_workspace" do
        expect(@project.is_workspace).to eq(false)
      end

      it "#schemes returns all available schemes" do
        expect(@project.schemes).to eq(["Example"])
      end

      it "#configurations returns all available configurations" do
        expect(@project.configurations).to eq(["Debug", "Release"])
      end

      it "#app_name" do
        expect(@project.app_name).to eq("ExampleProductName")
      end
    end

    describe "Valid CocoaPods Project" do
      before do
        options = { workspace: "./examples/cocoapods/Example.xcworkspace", scheme: "Example" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        @workspace = Gym::Project.new(Gym.config)
      end

      it "#schemes returns all schemes" do
        expect(@workspace.schemes).to eq(["Example", "HexColors", "Pods-Example"])
      end

      it "#schemes returns all configurations" do
        expect(@workspace.configurations).to eq([])
      end
    end
  end
end
