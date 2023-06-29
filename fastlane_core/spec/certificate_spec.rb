describe FastlaneCore do
  describe FastlaneCore::Certificate do
    describe "#parse_from_b64" do
      it "should parse the cert correctly" do
        cert_path = File.join(__dir__, "fixtures/signing/certificates/Certificate.cer")
        b64_encoded = Base64.encode64(File.read(cert_path))
        # Check that the certificate contains 230629152132Z as NotBefore
        parsed_cert = FastlaneCore::Certificate.parse_from_b64(b64_encoded)
        expect(parsed_cert["NotBefore"]).to eq(Time.parse("2023-06-29 15:21:32 UTC"))
      end

    end
    describe "#parse_from_file" do
      it "should parse the cert correctly" do
        cert_path = File.join(__dir__, "fixtures/signing/certificates/Certificate.cer")
        # Check that the certificate contains 230629152132Z as NotBefore
        parsed_cert = FastlaneCore::Certificate.parse_from_file(cert_path)
        expect(parsed_cert["NotBefore"]).to eq(Time.parse("2023-06-29 15:21:32 UTC"))
      end
    end
    describe "#order_by_expiration" do
      it "should order the certificates correctly ascending" do
        cert1_path = File.join(__dir__, "fixtures/signing/certificates/Certificate.cer")
        cert2_path = File.join(__dir__, "fixtures/signing/certificates/OtherCertificate.cer")
        cert1 = FastlaneCore::Certificate.parse_from_file(cert1_path)
        cert2 = FastlaneCore::Certificate.parse_from_file(cert2_path)
        expect(FastlaneCore::Certificate.order_by_expiration([cert1, cert2])).to eq([cert2, cert1])
      end
      it "should order the certificates correctly descending" do
        cert1_path = File.join(__dir__, "fixtures/signing/certificates/Certificate.cer")
        cert2_path = File.join(__dir__, "fixtures/signing/certificates/OtherCertificate.cer")
        cert1 = FastlaneCore::Certificate.parse_from_file(cert1_path)
        cert2 = FastlaneCore::Certificate.parse_from_file(cert2_path)
        expect(FastlaneCore::Certificate.order_by_expiration([cert1, cert2], false)).to eq([cert1, cert2])
      end
    end
  end
end
