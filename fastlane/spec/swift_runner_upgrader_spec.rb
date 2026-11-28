describe Fastlane::SwiftRunnerUpgrader do
  around do |example|
    Dir.mktmpdir do |dir|
      @swift = File.join(dir, 'swift')
      FileUtils.cp_r(File.join(Fastlane::ROOT, 'swift'), @swift)
      example.run
    end
  end

  let(:project_path) { File.join(@swift, 'FastlaneSwiftRunner', 'FastlaneSwiftRunner.xcodeproj') }

  before do
    allow(Fastlane::Setup).to receive(:setup_swift_support)
    allow(FastlaneCore::FastlaneFolder).to receive(:swift_folder_path).and_return("#{@swift}/")
    allow(FastlaneCore::FastlaneFolder).to receive(:swift_runner_project_path).and_return(project_path)
  end

  it 'ignores a group of the user inside the "Fastlane Runner" group' do
    project = Xcodeproj::Project.open(project_path)
    group = project.groups.find { |g| g.name == 'Fastlane Runner' }.new_group('Constants')
    project.targets.find { |t| t.name == 'FastlaneRunner' }.source_build_phase.add_file_reference(group.new_file('../Constants.swift'))
    project.save

    upgrader = described_class.new
    expect(upgrader.upgrade_if_needed!(dry_run: true)).to be(false)
    upgrader.upgrade_if_needed!

    group = Xcodeproj::Project.open(project_path).groups.find { |g| g.name == 'Fastlane Runner' }.groups.find { |g| g.name == 'Constants' }
    expect(group.files.map(&:name)).to eq(['Constants.swift'])
  end
end
