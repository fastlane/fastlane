describe Fastlane::Actions::CommitVersionBumpAction do
  let (:action) { Fastlane::Actions::CommitVersionBumpAction }

  describe 'settings_plists_from_param' do
    it 'returns the param in an array if a String' do
      settings_plists = action.settings_plists_from_param "About.plist"
      expect(settings_plists).to eq ["About.plist"]
    end

    it 'returns the param if an Array' do
      settings_plists = action.settings_plists_from_param ["About.plist", "Root.plist"]
      expect(settings_plists).to eq ["About.plist", "Root.plist"]
    end

    it 'returns ["Root.plist"] for any other input' do
      settings_plists = action.settings_plists_from_param true
      expect(settings_plists).to eq ["Root.plist"]
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
