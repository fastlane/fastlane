require 'sigh/local_manage'

describe Sigh::LocalManage do
  describe ".cleanup_profiles" do
    let(:dir) { Dir.mktmpdir("sigh-manage") }

    before do
      File.write(File.join(dir, "Old_App.mobileprovision"), "fake")
      File.write(File.join(dir, "Current_App.mobileprovision"), "fake")
      allow(FastlaneCore::ProvisioningProfile).to receive(:profiles_path).and_return(dir)
      allow(FastlaneCore::ProvisioningProfile).to receive(:parse) do |path|
        name = File.basename(path, ".mobileprovision")
        { "Name" => name, "ExpirationDate" => name == "Old_App" ? DateTime.now - 10 : DateTime.now + 100 }
      end
    end

    after { FileUtils.rm_rf(dir) }

    it "says so and asks nothing when no profile matches" do
      allow(FastlaneCore::Helper).to receive(:ci?).and_return(false)
      expect(FastlaneCore::UI).to receive(:important).with("No provisioning profiles that are either expired or match your pattern found")
      expect(FastlaneCore::UI).not_to receive(:confirm)

      described_class.cleanup_profiles(false, /nomatch/, nil)
      expect(Dir.children(dir).count).to eq(2)
    end

    it "still deletes the expired profiles" do
      described_class.cleanup_profiles(true, nil, true)
      expect(Dir.children(dir)).to eq(["Current_App.mobileprovision"])
    end
  end
end
