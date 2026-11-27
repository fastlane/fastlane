describe Snapshot::Collector do
  describe ".import_screenshots_from_result_bundle" do
    let(:screenshots_dir) { Dir.mktmpdir("snapshot_screenshots") }

    before { stub_const("Snapshot::SCREENSHOTS_DIR", screenshots_dir) }
    after { FileUtils.rm_rf(screenshots_dir) }

    # Stands in for `xcresulttool export attachments`, which writes the files and a manifest.json
    def stub_export(attachments)
      allow(FastlaneCore::CommandExecutor).to receive(:execute) do |command:|
        expect(command.first(4)).to eq(["xcrun", "xcresulttool", "export", "attachments"])
        output_dir = command[command.index("--output-path") + 1]
        attachments.each { |a| File.write(File.join(output_dir, a["exportedFileName"]), "png #{a['exportedFileName']}") }
        File.write(File.join(output_dir, "manifest.json"), [{ "testIdentifier" => "UITests/testExample()", "attachments" => attachments }].to_json)
      end
    end

    it "copies each screenshot under its attachment name" do
      stub_export([
                    { "exportedFileName" => "AAA.png", "suggestedHumanReadableName" => "MacBook-0Launch_0_DC34DDC5-05F3-4580-A5D6-454560C3B4DA.png" },
                    { "exportedFileName" => "BBB.png", "suggestedHumanReadableName" => "MacBook-1_Settings_screen_1_6590CEEE-E19C-48D7-82AA-8E2B73AC6A3B.png" }
                  ])

      Snapshot::Collector.import_screenshots_from_result_bundle("/path/to/Example.xcresult")

      expect(Dir.children(Snapshot::SCREENSHOTS_DIR).sort).to eq(["MacBook-0Launch.png", "MacBook-1_Settings_screen.png"])
      expect(File.read(File.join(Snapshot::SCREENSHOTS_DIR, "MacBook-0Launch.png"))).to eq("png AAA.png")
    end

    it "ignores attachments that are not named by SnapshotHelper" do
      stub_export([{ "exportedFileName" => "CCC.txt", "suggestedHumanReadableName" => "Debug log_0_DC34DDC5-05F3-4580-A5D6-454560C3B4DA.txt" }])

      Snapshot::Collector.import_screenshots_from_result_bundle("/path/to/Example.xcresult")

      expect(Dir.children(Snapshot::SCREENSHOTS_DIR)).to be_empty
    end
  end
end
