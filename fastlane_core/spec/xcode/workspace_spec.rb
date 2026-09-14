describe FastlaneCore::Xcode::Workspace do
  let(:dir) { Dir.mktmpdir("fl_xcode_workspace") }
  after { FileUtils.remove_entry(dir) }

  def write_workspace(contents)
    path = File.join(dir, "App.xcworkspace")
    FileUtils.mkdir_p(path)
    File.write(File.join(path, "contents.xcworkspacedata"), contents)
    path
  end

  it "reads file references, prepending group: paths of enclosing groups (container: paths are workspace-relative)" do
    path = write_workspace(<<~XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <Workspace version="1.0">
        <FileRef location="group:App.xcodeproj"></FileRef>
        <Group location="group:Modules" name="Modules">
          <Group location="container:Nested" name="Nested">
            <FileRef location="group:Deep/Deep.xcodeproj"></FileRef>
          </Group>
          <FileRef location="group:Module.xcodeproj"></FileRef>
          <FileRef location="container:Container.xcodeproj"></FileRef>
        </Group>
        <FileRef location="absolute:/tmp/Abs.xcodeproj"></FileRef>
        <FileRef location="group:README.md"></FileRef>
      </Workspace>
    XML
    workspace = FastlaneCore::Xcode::Workspace.open(path)
    expect(workspace.file_references.map { |r| [r.path, r.type] }).to eq([
                                                                           ["App.xcodeproj", "group"],
                                                                           ["Nested/Deep/Deep.xcodeproj", "group"],
                                                                           ["Modules/Module.xcodeproj", "group"],
                                                                           ["Container.xcodeproj", "container"],
                                                                           ["/tmp/Abs.xcodeproj", "absolute"],
                                                                           ["README.md", "group"]
                                                                         ])
    expect(workspace.project_paths).to eq([
                                            File.join(dir, "App.xcodeproj"),
                                            File.join(dir, "Nested/Deep/Deep.xcodeproj"),
                                            File.join(dir, "Modules/Module.xcodeproj"),
                                            File.join(dir, "Container.xcodeproj"),
                                            "/tmp/Abs.xcodeproj"
                                          ])
  end

  it "rejects developer file references" do
    reference = FastlaneCore::Xcode::Workspace::FileReference.new("Foo.xcodeproj", "developer")
    expect { reference.absolute_path(dir) }.to raise_error(FastlaneCore::Xcode::Error, /not yet supported/)
  end

  it "maps schemes to the project or workspace that defines them" do
    path = write_workspace(<<~XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <Workspace version="1.0">
        <FileRef location="group:Shared.xcodeproj"></FileRef>
        <FileRef location="group:NoSchemes.xcodeproj"></FileRef>
        <FileRef location="group:loose-file.txt"></FileRef>
      </Workspace>
    XML
    FileUtils.mkdir_p(File.join(dir, "Shared.xcodeproj/xcshareddata/xcschemes"))
    FileUtils.touch(File.join(dir, "Shared.xcodeproj/xcshareddata/xcschemes/SharedScheme.xcscheme"))
    FileUtils.mkdir_p(File.join(dir, "NoSchemes.xcodeproj"))
    FileUtils.mkdir_p(File.join(path, "xcshareddata/xcschemes"))
    FileUtils.touch(File.join(path, "xcshareddata/xcschemes/WorkspaceScheme.xcscheme"))
    FileUtils.touch(File.join(dir, "loose-file.txt"))

    expect(FastlaneCore::Xcode::Workspace.open(path).schemes).to eq({
      "SharedScheme" => File.join(dir, "Shared.xcodeproj"),
      "NoSchemes" => File.join(dir, "NoSchemes.xcodeproj"),
      "WorkspaceScheme" => path
    })
  end

  it "is empty when the workspace has no contents file" do
    path = File.join(dir, "Empty.xcworkspace")
    FileUtils.mkdir_p(path)
    workspace = FastlaneCore::Xcode::Workspace.open(path)
    expect(workspace.file_references).to eq([])
    expect(workspace.schemes).to eq({})
  end

  it "reads a real workspace" do
    workspace = FastlaneCore::Xcode::Workspace.open("./fastlane_core/spec/fixtures/projects/workspace_schemes/WorkspaceSchemes.xcworkspace")
    expect(workspace.schemes.keys).to eq(["WorkspaceSchemesFramework", "WorkspaceSchemesApp", "WorkspaceSchemesScheme"])
  end
end
