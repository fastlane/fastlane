describe Fastlane::Actions::CommitVersionBumpAction do
  let (:action) { Fastlane::Actions::CommitVersionBumpAction }

  describe 'settings_plists_from_param' do
    it 'returns the param in an array if a String' do
      settings_plists = action.settings_plists_from_param "About.plist"
      expect(settings_plists).to eq ["About.plist"]
    end

    it 'returns the param if an Array' do
      settings_plists = action.settings_plists_from_param %w{About.plist Root.plist}
      expect(settings_plists).to eq %w{About.plist Root.plist}
    end

    it 'returns ["Root.plist"] for any other input' do
      settings_plists = action.settings_plists_from_param true
      expect(settings_plists).to eq ["Root.plist"]
    end
  end

  describe 'include_list_from_param' do
    it 'returns an empty array for a nil argument' do
      include_list = action.include_list_from_param nil
      expect(include_list).to be_an Array
      expect(include_list).to be_empty
    end

    it 'splits a comma-separated String into an Array' do
      include_list = action.include_list_from_param "relative/path1,relative/path2"
      expect(include_list).to eq %w{relative/path1 relative/path2}
    end

    it 'returns the param if an Array' do
      include_list = action.include_list_from_param %w{relative/path1 relative/path2}
      expect(include_list).to eq %w{relative/path1 relative/path2}
    end

    it 'returns nil for any other type' do
      include_list = action.include_list_from_param true
      expect(include_list).to be_nil
    end
  end

  describe 'settings_bundle_file_path' do
    it 'returns the path of a file in the settings bundle from an Xcodeproj::Project' do
      settings_bundle = double "file", path: "Settings.bundle", real_path: "/path/to/MyApp/Settings.bundle"
      xcodeproj = double "xcodeproj", files: [settings_bundle]

      file_path = action.settings_bundle_file_path xcodeproj, "Root.plist"

      expect(file_path).to eq "/path/to/MyApp/Settings.bundle/Root.plist"
    end

    it 'raises if no settings bundle in the project' do
      xcodeproj = double "xcodeproj", files: []

      expect do
        action.settings_bundle_file_path xcodeproj, "Root.plist"
      end.to raise_error RuntimeError
    end
  end
end
