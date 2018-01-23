describe FastlaneCore::FastlaneFolder do
  let(:fastfile_name) { "Fastfile" }
  describe "#path" do
    it "returns the fastlane path if it exists" do
      expect(FastlaneCore::FastlaneFolder.path).to eq("./fastlane/")
    end

    it "returns nil if the fastlane path isn't available" do
      Dir.chdir("/") do
        expect(FastlaneCore::FastlaneFolder.path).to eq(nil)
      end
    end

    it "returns the path if fastlane is being executed from the fastlane directory" do
      Dir.chdir("fastlane") do
        expect(FastlaneCore::FastlaneFolder.path).to eq('./')
      end
    end
  end

  describe "#fastfile_path" do
    it "uses a Fastfile that's inside a fastlane directory" do
      expect(FastlaneCore::FastlaneFolder.fastfile_path).to eq(File.join(".", "fastlane", fastfile_name))
    end

    it "uses a Fastfile that's inside a fastlane directory if cd is inside a fastlane dir" do
      Dir.chdir("fastlane") do
        expect(FastlaneCore::FastlaneFolder.fastfile_path).to eq(File.join(".", fastfile_name))
      end
    end

    it "doesn't try to use a Fastfile if it's not inside a fastlane folder" do
      Dir.chdir("sigh") do
        File.write(fastfile_name, "")
        begin
          expect(FastlaneCore::FastlaneFolder.fastfile_path).to eq(nil)
        rescue RSpec::Expectations::ExpectationNotMetError => ex
          raise ex
        ensure
          File.delete(fastfile_name)
        end
      end
    end
  end
end
