describe Fastlane::Actions::CommitVersionBumpAction do
  let(:action) { Fastlane::Actions::CommitVersionBumpAction }

  describe 'settings_plists_from_param' do
    it 'returns the param in an array if a String' do
      settings_plists = action.settings_plists_from_param("About.plist")
      expect(settings_plists).to eq(["About.plist"])
    end

    it 'returns the param if an Array' do
      settings_plists = action.settings_plists_from_param(["About.plist", "Root.plist"])
      expect(settings_plists).to eq(["About.plist", "Root.plist"])
    end

    it 'returns ["Root.plist"] for any other input' do
      settings_plists = action.settings_plists_from_param(true)
      expect(settings_plists).to eq(["Root.plist"])
    end
  end

  describe 'settings_bundle_file_path' do
    it 'returns the path of a file in the settings bundle from an Xcodeproj::Project' do
      settings_bundle = double("file", path: "Settings.bundle", real_path: "/path/to/MyApp/Settings.bundle")
      xcodeproj = double("xcodeproj", files: [settings_bundle])

      file_path = action.settings_bundle_file_path(xcodeproj, "Root.plist")

      expect(file_path).to eq("/path/to/MyApp/Settings.bundle/Root.plist")
    end

    it 'raises if no settings bundle in the project' do
      xcodeproj = double("xcodeproj", files: [])

      expect do
        action.settings_bundle_file_path(xcodeproj, "Root.plist")
      end.to raise_error(RuntimeError)
    end
  end

  describe 'modified_files_relative_to_repo_root' do
    it 'returns an empty array if modified_files is nil' do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MODIFIED_FILES] = nil
      expect(action.modified_files_relative_to_repo_root("/path/to/repo/root")).to be_empty
    end

    it 'returns a list of relative paths given a list of possibly absolute paths' do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MODIFIED_FILES] =
        Set.new(%w{relative/path1 /path/to/repo/root/relative/path2})
      relative_paths = action.modified_files_relative_to_repo_root("/path/to/repo/root")
      expect(relative_paths).to eq(%w{relative/path1 relative/path2})
    end

    it 'removes duplicates' do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MODIFIED_FILES] =
        Set.new(%w{relative/path /path/to/repo/root/relative/path})
      relative_paths = action.modified_files_relative_to_repo_root("/path/to/repo/root")
      expect(relative_paths).to eq(["relative/path"])
    end
  end

  describe 'Actions::add_modified_files' do
    it 'adds an array of paths to the list, initializing to [] if nil' do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MODIFIED_FILES] = nil
      Fastlane::Actions.add_modified_files(%w{relative/path1 /path/to/repo/root/relative/path2})
      expected = Set.new(%w{relative/path1 /path/to/repo/root/relative/path2})
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MODIFIED_FILES]).to eq(expected)
    end

    it 'ignores duplicates' do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MODIFIED_FILES] = Set.new(["relative/path"])
      Fastlane::Actions.add_modified_files(["relative/path"])
      expected = Set.new(["relative/path"])
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MODIFIED_FILES]).to eq(expected)
    end
  end

  describe 'build_git_command' do
    it 'creates a git commit with the provided message' do
      command = action.build_git_command(message: "my commit message")

      expect(command).to eq("git commit -m 'my commit message'")
    end

    it 'creates a commit message containing the build number if no message is provided' do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER] = "123"
      command = action.build_git_command(no_verify: false)

      expect(command).to eq("git commit -m 'Version Bump to 123'")
    end

    it 'creates a default commit message if no message or build number is provided' do
      command = action.build_git_command(no_verify: false)

      expect(command).to eq("git commit -m 'Version Bump'")
    end

    it 'appends the --no-verify if required' do
      command = action.build_git_command(message: "my commit message", no_verify: true)

      expect(command).to eq("git commit -m 'my commit message' --no-verify")
    end
  end
end
