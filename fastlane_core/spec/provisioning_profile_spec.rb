describe FastlaneCore do
  describe FastlaneCore::ProvisioningProfile do
    describe "#profiles_path" do
      ["16.0", "17"].each do |xcode_version|
        it "returns correct profiles path for Xcode #{xcode_version}" do
          allow(FastlaneCore::Helper).to receive(:xcode_version).and_return(xcode_version)

          expect(FastlaneCore::ProvisioningProfile.profiles_path).to eq(File.expand_path("~/Library/Developer/Xcode/UserData/Provisioning Profiles"))
        end
      end

      ["10", "15"].each do |xcode_version|
        it "returns correct profiles path for Xcode #{xcode_version}" do
          allow(FastlaneCore::Helper).to receive(:xcode_version).and_return(xcode_version)

          expect(FastlaneCore::ProvisioningProfile.profiles_path).to eq(File.expand_path("~/Library/MobileDevice/Provisioning Profiles"))
        end
      end
    end

    describe "#parse" do
      let(:plist) { Plist::Emit.dump({ "Name" => "profile", "UUID" => "1234", "TeamIdentifier" => ["TEAM"], "AppIDName" => "App", "Version" => 1, "TimeToLive" => 1 }) }

      before do
        allow(FastlaneCore::Helper).to receive(:mac?).and_return(true)
      end

      it "decodes through the security gem into the keychain it is given" do
        expect(Security::ProvisioningProfile).to receive(:decode).with("/a b.mobileprovision", keychain: "/a.keychain-db").and_return(plist)

        expect(FastlaneCore::ProvisioningProfile.parse("/a b.mobileprovision", "/a.keychain-db")["UUID"]).to eq("1234")
      end

      it "leaves the keychain to security when none is given" do
        expect(Security::ProvisioningProfile).to receive(:decode).with("/a.mobileprovision", keychain: nil).and_return(plist)

        FastlaneCore::ProvisioningProfile.parse("/a.mobileprovision")
      end

      it "reports a profile security cannot decode" do
        allow(Security::ProvisioningProfile).to receive(:decode).and_raise(Security::Error.new(1, "security: failed to decode message\n"))
        expect(FastlaneCore::UI).to receive(:error).with("Failure to decode /a.mobileprovision: security: failed to decode message (status 1)")

        expect { FastlaneCore::ProvisioningProfile.parse("/a.mobileprovision") }
          .to raise_error(FastlaneCore::Interface::FastlaneCrash, "Error parsing provisioning profile at path '/a.mobileprovision'")
      end
    end
  end
end
