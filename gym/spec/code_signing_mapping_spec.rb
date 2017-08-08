describe Gym::CodeSigningMapping do
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

    it "Strips out all the usual characters that are not needed" do
      csm = Gym::CodeSigningMapping.new(project: nil)
      return_value = csm.app_identifier_contains?("Ad-HocValue", "ad-hoc")
      expect(return_value).to eq(true)
    end
  end

  describe "#detect_project_profile_mapping" do
    it "returns the mapping of the selected provisioning profiles" do
      workspace_path = "gym/spec/fixtures/projects/cocoapods/Example.xcworkspace"
      project = FastlaneCore::Project.new({
        workspace: workspace_path
      })

      csm = Gym::CodeSigningMapping.new(project: project)
      expect(csm.detect_project_profile_mapping).to eq({ "family.wwdc.app" => "match AppStore family.wwdc.app" })
    end
  end

  describe "#merge_profile_mapping" do
    let (:csm) { Gym::CodeSigningMapping.new }

    it "only mapping from Xcode Project is available" do
      expect(csm).to receive(:detect_project_profile_mapping).and_return({ "identifier.1" => "value.1" })
      result = csm.merge_profile_mapping(existing_mapping: {}, export_method: "app-store")

      expect(result).to eq({ "identifier.1" => "value.1" })
    end

    it "only mapping from match (user) is available" do
      expect(csm).to receive(:detect_project_profile_mapping).and_return({})
      result = csm.merge_profile_mapping(existing_mapping: { "identifier.1" => "value.1" }, export_method: "app-store")

      expect(result).to eq({ "identifier.1" => "value.1" })
    end

    it "keeps both profiles if they don't conflict" do
      expect(csm).to receive(:detect_project_profile_mapping).and_return({ "identifier.2" => "value.2" })
      result = csm.merge_profile_mapping(existing_mapping: { "identifier.1" => "value.1" }, export_method: "app-store")

      expect(result).to eq({ "identifier.1" => "value.1", "identifier.2" => "value.2" })
    end

    describe "handle conflicts" do
      it "Both Xcode project and match (user) are available, and both match the export method, it should prefer the user input (match)" do
        expect(csm).to receive(:detect_project_profile_mapping).and_return({ "identifier.1" => "Ap-pStoreValue1" })
        result = csm.merge_profile_mapping(existing_mapping: { "identifier.1" => "Ap-pStoreValue2" }, export_method: "app-store")

        expect(result).to eq({ "identifier.1" => "Ap-pStoreValue2" })
      end

      it "Both Xcode project and match (user) are available, and and the match (user) is the only one that matches the export type" do
        expect(csm).to receive(:detect_project_profile_mapping).and_return({ "identifier.1" => "Ad-HocValue" })
        result = csm.merge_profile_mapping(existing_mapping: { "identifier.1" => "Ap-p StoreValue1" }, export_method: "app-store")

        expect(result).to eq({ "identifier.1" => "Ap-p StoreValue1" })
      end

      it "Both Xcode project and match (user) are available, and and the Xcode project is the only one that matches the export type" do
        expect(csm).to receive(:detect_project_profile_mapping).and_return({ "identifier.1" => "Ad-HocValue" })
        result = csm.merge_profile_mapping(existing_mapping: { "identifier.1" => "Ap-p StoreValue1" }, export_method: "ad-hoc")

        expect(result).to eq({ "identifier.1" => "Ad-HocValue" })
      end
    end
  end
end
