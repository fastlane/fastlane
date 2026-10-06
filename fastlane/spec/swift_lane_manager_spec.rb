describe Fastlane::SwiftLaneManager do
  describe '.ensure_runner_built!' do
    let(:built_at) { Time.now - 3600 }

    around do |example|
      Dir.mktmpdir do |dir|
        @folder = dir
        FileUtils.mkdir_p(File.join(dir, 'swift'))
        example.run
      end
    end

    before do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(@folder)
      allow(described_class).to receive(:link_user_configs_to_project).and_return(false)
    end

    # Creates the file with this modification time
    def file(relative_path, modified_at)
      path = File.join(@folder, relative_path)
      FileUtils.touch(path)
      File.utime(modified_at, modified_at, path)
    end

    def build_runner(runner_files_modified_at:, fastfile_modified_at: built_at - 60)
      file('FastlaneRunner', built_at)
      file('Fastfile.swift', fastfile_modified_at)
      file('swift/RubyCommandable.swift', runner_files_modified_at)
      file('swift/Gymfile.swift', built_at - 60)
    end

    it 'does not rebuild a runner newer than all its sources' do
      build_runner(runner_files_modified_at: built_at - 60)
      expect(described_class).not_to receive(:build_runner!)

      described_class.ensure_runner_built!
    end

    it 'rebuilds the runner when the Fastfile changed' do
      build_runner(runner_files_modified_at: built_at - 60, fastfile_modified_at: built_at + 60)
      expect(described_class).to receive(:build_runner!)

      described_class.ensure_runner_built!
    end

    it 'rebuilds the runner when one of its own files changed, as after pulling an upgraded runner' do
      build_runner(runner_files_modified_at: built_at + 60)
      expect(described_class).to receive(:build_runner!)

      described_class.ensure_runner_built!
    end
  end
end
