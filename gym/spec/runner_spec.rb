describe Gym::Runner do
  describe "#compress_and_move_dsym" do
    it "zips the dSYM when the archive name contains an apostrophe" do
      Dir.mktmpdir do |tmp|
        dsyms_directory = File.join(tmp, "Kaldi's Kafe 2016-09-26 15.05.33.xcarchive", "dSYMs")
        dsym_path = File.join(dsyms_directory, "Kaldi's Kafe.app.dSYM")
        FileUtils.mkdir_p(File.join(dsym_path, "Contents"))
        File.write(File.join(dsym_path, "Contents", "Info.plist"), "")
        output_directory = File.join(tmp, "output")
        FileUtils.mkdir_p(output_directory)

        allow(Gym::PackageCommandGenerator).to receive(:dsym_path).and_return(dsym_path)
        allow(Gym).to receive(:config).and_return({ output_directory: output_directory, output_name: "Kaldi's Kafe", silent: true })

        Gym::Runner.new.send(:compress_and_move_dsym)

        zip_path = File.join(output_directory, "Kaldi's Kafe.app.dSYM.zip")
        expect(File.exist?(zip_path)).to be(true)
        expect(`unzip -Z1 #{zip_path.shellescape}`.lines.map(&:chomp)).to include("Kaldi's Kafe.app.dSYM/Contents/Info.plist")
      end
    end

    it "prints the path of the dSYM zip" do
      Dir.mktmpdir do |tmp|
        dsym_path = File.join(tmp, "App.xcarchive", "dSYMs", "App.app.dSYM")
        FileUtils.mkdir_p(File.join(dsym_path, "Contents"))
        File.write(File.join(dsym_path, "Contents", "Info.plist"), "")
        output_directory = File.join(tmp, "output")
        FileUtils.mkdir_p(output_directory)

        allow(Gym::PackageCommandGenerator).to receive(:dsym_path).and_return(dsym_path)
        allow(Gym).to receive(:config).and_return({ output_directory: output_directory, output_name: "App", silent: true })

        allow(FastlaneCore::UI).to receive(:message).and_call_original
        expect(FastlaneCore::UI).to receive(:message).with(File.join(File.expand_path(output_directory), "App.app.dSYM.zip"))
        Gym::Runner.new.send(:compress_and_move_dsym)
      end
    end

    it "fails when zip cannot write the archive" do
      Dir.mktmpdir do |tmp|
        dsym_path = File.join(tmp, "App.xcarchive", "dSYMs", "App.app.dSYM")
        FileUtils.mkdir_p(File.join(dsym_path, "Contents"))
        File.write(File.join(dsym_path, "Contents", "Info.plist"), "")

        allow(Gym::PackageCommandGenerator).to receive(:dsym_path).and_return(dsym_path)
        allow(Gym).to receive(:config).and_return({ output_directory: File.join(tmp, "missing"), output_name: "App", silent: true })

        expect do
          Gym::Runner.new.send(:compress_and_move_dsym)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Could not compress the dSYM/)
      end
    end
  end

  describe "#copy_mac_app" do
    it "fails naming the archive when it contains no .app" do
      Dir.mktmpdir do |tmp|
        archive_path = File.join(tmp, "App.xcarchive")
        FileUtils.mkdir_p(File.join(archive_path, "Products", "Applications"))

        allow(Gym).to receive(:project).and_return(double("project", build_settings: "App"))
        allow(Gym).to receive(:config).and_return({ output_directory: tmp })
        allow(Gym::BuildCommandGenerator).to receive(:archive_path).and_return(archive_path)

        expect do
          Gym::Runner.new.send(:copy_mac_app)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find application in '#{archive_path}'")
      end
    end
  end
end
