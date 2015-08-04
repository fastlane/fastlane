describe Gym do
  describe Gym::Project do
    it "raises an exception if path was not found" do
      expect do
        Gym::Project.new(project: "/tmp/notHere123")
      end.to raise_error "Could not find project at path '/tmp/notHere123'".red
    end

    describe "Valid Project" do
      before do
        options = { project: "./example/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        @project = Gym::Project.new(Gym.config)
      end

      it "#path" do
        expect(@project.path).to eq(File.expand_path("./example/Example.xcodeproj"))
      end

      it "#is_workspace" do
        expect(@project.is_workspace).to eq(false)
      end

      it "#schemes returns all available schemes" do
        expect(@project.schemes).to eq(["Example"])
      end

      it "#app_name" do
        expect(@project.app_name).to eq("ExampleProductName")
      end
    end
  end
end
