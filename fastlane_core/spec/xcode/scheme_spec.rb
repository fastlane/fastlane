describe FastlaneCore::Xcode::Scheme do
  let(:dir) { Dir.mktmpdir("fl_xcode_scheme") }
  after { FileUtils.remove_entry(dir) }

  def write_scheme(archive_action)
    path = File.join(dir, "App.xcscheme")
    File.write(path, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Scheme version=\"1.3\">\n<BuildAction/>\n#{archive_action}\n</Scheme>\n")
    path
  end

  it "reads the archive build configuration" do
    path = write_scheme('<ArchiveAction buildConfiguration="Staging" revealArchiveInOrganizer="YES"></ArchiveAction>')
    expect(FastlaneCore::Xcode::Scheme.new(path).archive_build_configuration).to eq("Staging")
  end

  it "defaults to Release when the scheme has no archive action" do
    expect(FastlaneCore::Xcode::Scheme.new(write_scheme("")).archive_build_configuration).to eq("Release")
  end

  it "reads a real scheme" do
    path = "./fastlane_core/spec/fixtures/projects/Example.xcodeproj/xcshareddata/xcschemes/Example.xcscheme"
    expect(FastlaneCore::Xcode::Scheme.new(path).archive_build_configuration).to eq("Release")
  end
end
