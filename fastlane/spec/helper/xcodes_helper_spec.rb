describe Fastlane::Helper::XcodesHelper do
  describe ".read_xcode_version_file" do
    let(:xcode_version_path) { ".xcode-version" }

    context ".xcode-version file exists" do
      before do
        allow(Dir).to receive(:glob).with(".xcode-version").and_return([xcode_version_path])
        allow(File).to receive(:read).with(xcode_version_path).and_return("14")
      end

      it "returns its content" do
        expect(subject.class.read_xcode_version_file).to eq("14")
      end
    end

    context "no .xcode-version file exists" do
      before do
        allow(Dir).to receive(:glob).with(".xcode-version").and_return([])
      end

      it "returns nil" do
        expect(subject.class.read_xcode_version_file).to eq(nil)
      end
    end
  end

  describe ".find_xcodes_binary_path" do
    it "returns the binary path when it's installed" do
      expect(subject.class).to receive(:find_xcodes_binary_path).and_return("/path/to/bin/xcodes")
      expect(subject.class.find_xcodes_binary_path).to eq("/path/to/bin/xcodes")
    end

    it "returns an error message instead of a valid path when it's not installed" do
      expect(subject.class).to receive(:find_xcodes_binary_path).and_return("xcodes not found")
      expect(File.exist?(subject.class.find_xcodes_binary_path)).to eq(false)
    end
  end

  describe "Verify" do
    describe ".requirement" do
      context "when argument is missing or empty" do
        let(:argument) { nil }

        it "raises user error" do
          expect { subject.class::Verify.requirement(argument) }.to raise_error(FastlaneCore::Interface::FastlaneError, 'Version must be specified')
        end
      end
    end
  end
end
