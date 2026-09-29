describe Sigh::LocalManage do
  describe ".load_profiles" do
    def profile_xml(name)
      Plist::Emit.dump({ "Name" => name, "UUID" => name, "TeamIdentifier" => ["TEAM"], "AppIDName" => name, "Version" => 1, "TimeToLive" => 1 })
    end

    around do |example|
      Dir.mktmpdir do |dir|
        @dir = dir
        example.run
      end
    end

    before do
      allow(FastlaneCore::Helper).to receive(:mac?).and_return(true)
      allow(FastlaneCore::ProvisioningProfile).to receive(:profiles_path).and_return(@dir)
      allow(FastlaneCore::UI).to receive(:message)
      File.write(File.join(@dir, "b.mobileprovision"), "")
      File.write(File.join(@dir, "a b.mobileprovision"), "")
    end

    it "decodes each profile through the security gem, sorted by name" do
      expect(Security::ProvisioningProfile).to receive(:decode).with(File.join(@dir, "b.mobileprovision"), keychain: nil).and_return(profile_xml("Zulu"))
      expect(Security::ProvisioningProfile).to receive(:decode).with(File.join(@dir, "a b.mobileprovision"), keychain: nil).and_return(profile_xml("alpha"))

      profiles = Sigh::LocalManage.load_profiles

      expect(profiles.map { |profile| profile["Name"] }).to eq(["alpha", "Zulu"])
      expect(profiles.map { |profile| profile["Path"] }).to eq([File.join(@dir, "a b.mobileprovision"), File.join(@dir, "b.mobileprovision")])
    end

    it "names a profile security cannot decode" do
      allow(Security::ProvisioningProfile).to receive(:decode).and_raise(Security::Error.new(1, "security: failed to decode message\n"))
      allow(FastlaneCore::UI).to receive(:error)

      expect { Sigh::LocalManage.load_profiles }.to raise_error(FastlaneCore::Interface::FastlaneCrash, /Error parsing provisioning profile at path/)
    end
  end
end
