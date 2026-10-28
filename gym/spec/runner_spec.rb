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
  end
end
