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
  end
end
