describe Cert do
  describe Cert::Runner do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"
    end

    it "Successful run" do
      certificate = stub_certificate

      allow(Spaceship).to receive(:login).and_return(nil)
      allow(Spaceship).to receive(:client).and_return("client")
      allow(Spaceship).to receive(:select_team).and_return(nil)
      allow(Spaceship.client).to receive(:in_house?).and_return(false)
      allow(Spaceship.certificate.production).to receive(:all).and_return([certificate])

      allow(FastlaneCore::CertChecker).to receive(:installed?).and_return(true)

      options = { keychain_path: "." }
      Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options)

      Cert::Runner.new.launch
      expect(ENV["CER_CERTIFICATE_ID"]).to eq("cert_id")
      expect(ENV["CER_FILE_PATH"]).to eq("#{Dir.pwd}/cert_id.cer")
      File.delete(ENV["CER_FILE_PATH"])
    end

    it "correctly selects expired certificates" do
      expired_cert = stub_certificate(Time.now.utc - 1)
      good_cert = stub_certificate

      allow(Spaceship).to receive(:client).and_return("client")
      allow(Spaceship.client).to receive(:in_house?).and_return(false)
      allow(Spaceship.certificate.production).to receive(:all).and_return([expired_cert, good_cert])

      expect(Cert::Runner.new.expired_certs).to eq([expired_cert])
    end

    it "revokes expired certificates if so requested" do
      expired_cert = stub_certificate(Time.now.utc - 1)
      good_cert = stub_certificate

      allow(Spaceship).to receive(:login).and_return(nil)
      allow(Spaceship).to receive(:client).and_return("client")
      allow(Spaceship).to receive(:select_team).and_return(nil)
      allow(Spaceship.client).to receive(:in_house?).and_return(false)
      allow(Spaceship.certificate.production).to receive(:all).and_return([expired_cert, good_cert])

      allow(FastlaneCore::CertChecker).to receive(:installed?).and_return(true)

      expect(expired_cert).to receive(:revoke!)
      expect(good_cert).to_not receive(:revoke!)

      Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, revoke_expired: true, keychain_path: ".")
      Cert::Runner.new.run
    end

    it "does not revoke expired certificates unless requested" do
      expired_cert = stub_certificate(Time.now.utc - 1)
      good_cert = stub_certificate

      allow(Spaceship).to receive(:login).and_return(nil)
      allow(Spaceship).to receive(:client).and_return("client")
      allow(Spaceship).to receive(:select_team).and_return(nil)
      allow(Spaceship.client).to receive(:in_house?).and_return(false)
      allow(Spaceship.certificate.production).to receive(:all).and_return([expired_cert, good_cert])

      allow(FastlaneCore::CertChecker).to receive(:installed?).and_return(true)

      expect(expired_cert).to_not receive(:revoke!)
      expect(good_cert).to_not receive(:revoke!)

      Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, keychain_path: ".")
      Cert::Runner.new.run
    end
  end
end
