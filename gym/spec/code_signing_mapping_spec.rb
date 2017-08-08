describe Gym::CodeSigningMapping, now: true do
  describe "#project_paths" do
    it "works with basic projects" do
      project = FastlaneCore::Project.new({
        project: "gym/lib"
      })

      csm = Gym::CodeSigningMapping.new(project: project)
      expect(csm.project_paths).to be_an(Array)
      expect(csm.project_paths).to eq([File.expand_path("gym/lib")])
    end

    it "works with workspaces" do
      workspace_path = "gym/spec/fixtures/projects/cocoapods/Example.xcworkspace"
      project = FastlaneCore::Project.new({
        workspace: workspace_path
      })

      csm = Gym::CodeSigningMapping.new(project: project)
      expect(csm.project_paths).to eq([
        File.expand_path(workspace_path.gsub("xcworkspace", "xcodeproj")) # this should point to the included Xcode project
      ])
    end
  end

  describe "#app_identifier_contains?" do
    it "returns false if it doesn't contain it" do
      csm = Gym::CodeSigningMapping.new(project: nil)
      return_value = csm.app_identifier_contains?("dsfsdsdf", "somethingelse")
      expect(return_value).to eq(false)
    end

    it "returns true if it doesn't contain it" do
      csm = Gym::CodeSigningMapping.new(project: nil)
      return_value = csm.app_identifier_contains?("FuLL-StRing Yo", "fullstringyo")
      expect(return_value).to eq(true)
    end
  end

  describe "detect_project_profile_mapping" do
    it "returns the mapping of the selected provisioning profiles" do
      workspace_path = "gym/spec/fixtures/projects/cocoapods/Example.xcworkspace"
      project = FastlaneCore::Project.new({
        workspace: workspace_path
      })

      csm = Gym::CodeSigningMapping.new(project: project)
      expect(csm.detect_project_profile_mapping).to eq({"family.wwdc.app"=>"match AppStore family.wwdc.app"})
    end
  end
end
