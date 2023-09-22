describe FastlaneCore do
  describe FastlaneCore::ProvisioningProfile do
    describe "#includes_certificate" do
      it "should return true if the profile includes the certificate" do
        cert_path = File.join(__dir__, "fixtures/signing/certificates/Certificate.cer")
        profile_path = File.join(__dir__, "fixtures/signing/provisioning_profiles/Fastlane_PR_Unit_Tests.mobileprovision")
        expect(FastlaneCore::ProvisioningProfile.includes_certificate?(profile_path: profile_path, certificate_path: cert_path)).to eq(true)
      end
      it "should return true if the profile doesn't include the certificate" do
        cert_path = File.join(__dir__, "fixtures/signing/certificates/OtherCertificate.cer")
        profile_path = File.join(__dir__, "fixtures/signing/provisioning_profiles/Fastlane_PR_Unit_Tests.mobileprovision")
        expect(FastlaneCore::ProvisioningProfile.includes_certificate?(profile_path: profile_path, certificate_path: cert_path)).to eq(false)
      end
    end
  end
end
