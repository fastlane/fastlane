describe FastlaneCore do
  describe FastlaneCore::Project do
    it "raises an exception if path was not found" do
      expect do
        FastlaneCore::Project.new(project: "/tmp/notHere123")
      end.to raise_error "Could not find project at path '/tmp/notHere123'".red
    end

    describe "Valid Standard Project" do
      before do
        options = { project: "./spec/fixtures/projects/Example.xcodeproj" }
        @project = FastlaneCore::Project.new(options)
      end

      it "#path" do
        expect(@project.path).to eq(File.expand_path("./spec/fixtures/projects/Example.xcodeproj"))
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

      it "#mac?" do
        expect(@project.mac?).to eq(false)
      end

      it "#ios?" do
        expect(@project.ios?).to eq(true)
      end

      it "#tvos?" do
        expect(@project.tvos?).to eq(false)
      end
    end

    describe "Valid CocoaPods Project" do
      before do
        options = { workspace: "./spec/fixtures/projects/cocoapods/Example.xcworkspace", scheme: "Example" }
        @workspace = FastlaneCore::Project.new(options)
      end

      it "#schemes returns all schemes" do
        expect(@workspace.schemes).to eq(["Example"])
      end

      it "#schemes returns all configurations" do
        expect(@workspace.configurations).to eq([])
      end
    end

    describe "Mac Project" do
      before do
        options = { project: "./spec/fixtures/projects/Mac.xcodeproj" }
        @project = FastlaneCore::Project.new(options)
      end

      it "#mac?" do
        expect(@project.mac?).to eq(true)
      end

      it "#ios?" do
        expect(@project.ios?).to eq(false)
      end

      it "#tvos?" do
        expect(@project.tvos?).to eq(false)
      end

      it "schemes" do
        expect(@project.schemes).to eq(["Mac"])
      end
    end

    describe "TVOS Project" do
      before do
        options = { project: "./spec/fixtures/projects/ExampleTVOS.xcodeproj" }
        @project = FastlaneCore::Project.new(options)
      end

      it "#mac?" do
        expect(@project.mac?).to eq(false)
      end

      it "#ios?" do
        expect(@project.ios?).to eq(false)
      end

      it "#tvos?" do
        expect(@project.tvos?).to eq(true)
      end

      it "schemes" do
        expect(@project.schemes).to eq(["ExampleTVOS"])
      end
    end

    describe "Build Settings" do
      before do
        options = { project: "./spec/fixtures/projects/Example.xcodeproj" }
        @project = FastlaneCore::Project.new(options)
      end

      it "IPHONEOS_DEPLOYMENT_TARGET should be 9.0" do
        expect(@project.build_settings(key: "IPHONEOS_DEPLOYMENT_TARGET")).to eq("9.0")
      end
    end
  end
end
