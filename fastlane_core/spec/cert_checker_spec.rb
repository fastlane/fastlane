describe FastlaneCore do
  describe FastlaneCore::CertChecker do
    let(:success_status) {
      class ProcessStatusMock
      end

      allow_any_instance_of(ProcessStatusMock).to receive(:success?).and_return(true)

      ProcessStatusMock.new
    }

    describe '#installed_identities' do
      it 'should print an error when no local code signing identities are found' do
        allow(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5', 'G6', 'DEV-ID-G1', 'DEV-ID-G2'])
        allow(Security::Identity).to receive(:find).with(keychain: nil).and_return([])
        expect(FastlaneCore::UI).to receive(:error).with(/There are no local code signing identities found/)

        FastlaneCore::CertChecker.installed_identities
      end

      it 'should list the identities of the keychain it is given, skipping revoked ones' do
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5', 'G6', 'DEV-ID-G1', 'DEV-ID-G2'])
        identities = [
          Security::Identity.send(:new, "AAAA", "Apple Development: someone (TEAM)"),
          Security::Identity.send(:new, "BBBB", "Apple Distribution: someone (TEAM)", "CSSMERR_TP_CERT_REVOKED")
        ]
        expect(Security::Identity).to receive(:find).with(keychain: "/a b.keychain-db").and_return(identities)
        expect(FastlaneCore::UI).not_to(receive(:error))

        expect(FastlaneCore::CertChecker.installed_identities(in_keychain: "/a b.keychain-db")).to eq(["AAAA"])
      end

      it 'should report a keychain it cannot search' do
        allow(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5', 'G6', 'DEV-ID-G1', 'DEV-ID-G2'])
        allow(Security::Identity).to receive(:find).and_raise(Security::Error.new(50, "security: not allowed\n"))
        expect(FastlaneCore::UI).to receive(:error).with("Could not list the code signing identities: security: not allowed (status 50)")
        expect(FastlaneCore::UI).to receive(:error).with(/There are no local code signing identities found/)

        expect(FastlaneCore::CertChecker.installed_identities).to eq([])
      end
    end

    describe '#installed_wwdr_certificates' do
      let(:cert) do
        cert = OpenSSL::X509::Certificate.new
        key = OpenSSL::PKey::RSA.new(2048)
        root_key = OpenSSL::PKey::RSA.new(2048)
        cert.public_key = key.public_key
        cert.sign(root_key, OpenSSL::Digest::SHA256.new)
        cert
      end

      it "should return installed certificate's alias" do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')

        allow(Security::Certificate).to receive(:find).and_return([instance_double(Security::Certificate, pem: "-----BEGIN CERTIFICATE-----\nG6\n-----END CERTIFICATE-----\n")])

        allow(Digest::SHA256).to receive(:hexdigest).with(cert.to_der).and_return('bdd4ed6e74691f0c2bfd01be0296197af1379e0418e2d300efa9c3bef642ca30')
        allow(OpenSSL::X509::Certificate).to receive(:new).and_return(cert)

        expect(FastlaneCore::CertChecker.installed_wwdr_certificates).to eq(['G6'])
      end

      it "should return an empty array if unknown WWDR certificates are found" do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')

        allow(Security::Certificate).to receive(:find).and_return([instance_double(Security::Certificate, pem: "-----BEGIN CERTIFICATE-----\nG6\n-----END CERTIFICATE-----\n")])

        allow(OpenSSL::X509::Certificate).to receive(:new).and_return(cert)

        expect(FastlaneCore::CertChecker.installed_wwdr_certificates).to eq([])
      end

      it "should find Developer ID certificates by their own common name" do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')

        expect(Security::Certificate).to receive(:find).with(name: 'Apple Worldwide Developer Relations', keychain: 'login.keychain').and_return([])
        expect(Security::Certificate).to receive(:find).with(name: 'Developer ID Certification Authority', keychain: 'login.keychain')
                                                       .and_return([instance_double(Security::Certificate, pem: "-----BEGIN CERTIFICATE-----\nDEV-ID-G2\n-----END CERTIFICATE-----\n")])

        allow(Digest::SHA256).to receive(:hexdigest).with(cert.to_der).and_return('f16cd3c54c7f83cea4bf1a3e6a0819c8aaa8e4a1528fd144715f350643d2df3a')
        allow(OpenSSL::X509::Certificate).to receive(:new).and_return(cert)

        expect(FastlaneCore::CertChecker.installed_wwdr_certificates).to eq(['DEV-ID-G2'])
      end
    end

    describe '#installed_installers' do
      it 'should list the SHA-1 of both kinds of installer certificates in the keychain' do
        expect(Security::Certificate).to receive(:find).with(name: "3rd Party Mac Developer Installer", keychain: "/a b.keychain-db")
                                                       .and_return([instance_double(Security::Certificate, sha1: "AAAA")])
        expect(Security::Certificate).to receive(:find).with(name: "Developer ID Installer", keychain: "/a b.keychain-db")
                                                       .and_return([instance_double(Security::Certificate, sha1: "BBBB")])

        expect(FastlaneCore::CertChecker.installed_installers(in_keychain: "/a b.keychain-db")).to eq(["AAAA", "BBBB"])
      end

      it 'should report a keychain it cannot search, and treat it as holding none' do
        allow(Security::Certificate).to receive(:find).and_raise(Security::Error.new(50, "security: not allowed\n"))
        expect(FastlaneCore::UI).to receive(:error).with("Could not search for '3rd Party Mac Developer Installer' certificates: security: not allowed (status 50)")
        expect(FastlaneCore::UI).to receive(:error).with("Could not search for 'Developer ID Installer' certificates: security: not allowed (status 50)")

        expect(FastlaneCore::CertChecker.installed_installers).to eq([])
      end
    end

    describe '#install_missing_wwdr_certificates' do
      it 'should install all official WWDR certificates' do
        allow(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return([])
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G2', { keychain: "login.keychain" })
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G3', { keychain: "login.keychain" })
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G4', { keychain: "login.keychain" })
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G5', { keychain: "login.keychain" })
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G6', { keychain: "login.keychain" })
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('DEV-ID-G1', { keychain: "login.keychain" })
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('DEV-ID-G2', { keychain: "login.keychain" })
        FastlaneCore::CertChecker.install_missing_wwdr_certificates
      end

      it 'should install the missing official WWDR certificate' do
        allow(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5', 'DEV-ID-G2'])
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G6', { keychain: "login.keychain" })
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('DEV-ID-G1', { keychain: "login.keychain" })
        FastlaneCore::CertChecker.install_missing_wwdr_certificates
      end

      it 'should download the WWDR certificate from correct URL' do
        allow(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')
        allow(Security::Certificate).to receive(:import).and_return(true)

        expect(Open3).to receive(:capture3).with(include('https://www.apple.com/certificateauthority/AppleWWDRCAG2.cer')).and_return(["", "", success_status])
        FastlaneCore::CertChecker.install_wwdr_certificate('G2')

        expect(Open3).to receive(:capture3).with(include('https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer')).and_return(["", "", success_status])
        FastlaneCore::CertChecker.install_wwdr_certificate('G3')

        expect(Open3).to receive(:capture3).with(include('https://www.apple.com/certificateauthority/AppleWWDRCAG4.cer')).and_return(["", "", success_status])
        FastlaneCore::CertChecker.install_wwdr_certificate('G4')

        expect(Open3).to receive(:capture3).with(include('https://www.apple.com/certificateauthority/AppleWWDRCAG5.cer')).and_return(["", "", success_status])
        FastlaneCore::CertChecker.install_wwdr_certificate('G5')

        expect(Open3).to receive(:capture3).with(include('https://www.apple.com/certificateauthority/AppleWWDRCAG6.cer')).and_return(["", "", success_status])
        FastlaneCore::CertChecker.install_wwdr_certificate('G6')

        expect(Open3).to receive(:capture3).with(include('https://www.apple.com/certificateauthority/DeveloperIDCA.cer')).and_return(["", "", success_status])
        FastlaneCore::CertChecker.install_wwdr_certificate('DEV-ID-G1')

        expect(Open3).to receive(:capture3).with(include('https://www.apple.com/certificateauthority/DeveloperIDG2CA.cer')).and_return(["", "", success_status])
        FastlaneCore::CertChecker.install_wwdr_certificate('DEV-ID-G2')
      end
    end

    describe '#install_wwdr_certificate' do
      before do
        allow(Open3).to receive(:capture3).and_return(["", "", success_status])
      end

      it 'should accept a certificate that is already installed' do
        allow(Security::Certificate).to receive(:import).and_raise(Security::DuplicateItemError.new(1, "security: SecKeychainItemImport: The specified item already exists in the keychain.\n"))

        expect(FastlaneCore::CertChecker.install_wwdr_certificate('G6', keychain: 'login.keychain')).to be(true)
      end

      it 'should fail when the certificate cannot be imported' do
        allow(Security::Certificate).to receive(:import).and_raise(Security::Error.new(1, "security: SecKeychainItemImport: The specified keychain could not be found.\n"))

        expect { FastlaneCore::CertChecker.install_wwdr_certificate('G6', keychain: 'login.keychain') }.to raise_error("Could not install WWDR certificate: security: SecKeychainItemImport: The specified keychain could not be found. (status 1)")
      end

      it 'should fail when the certificate cannot be downloaded, without importing' do
        failed = double(success?: false)
        allow(Open3).to receive(:capture3).and_return(["", "curl: (22) 404", failed])
        expect(Security::Certificate).not_to receive(:import)

        expect { FastlaneCore::CertChecker.install_wwdr_certificate('G6', keychain: 'login.keychain') }.to raise_error("Could not download WWDR certificate")
      end
    end

    describe '#wwdr_keychain' do
      it 'should prefer the default keychain' do
        allow(Security::Keychain).to receive(:default_keychain).and_return(Security::Keychain.new("/a/login.keychain-db"))

        expect(FastlaneCore::CertChecker.wwdr_keychain).to eq("/a/login.keychain-db")
      end

      it 'should fall back to the first keychain in the search list' do
        allow(Security::Keychain).to receive(:default_keychain).and_raise(Security::Error.new(50, "security: SecKeychainCopyDefault: A default keychain could not be found.\n"))
        allow(Security::Keychain).to receive(:list).with(:user).and_return([Security::Keychain.new("/a/other.keychain-db")])

        expect(FastlaneCore::CertChecker.wwdr_keychain).to eq("/a/other.keychain-db")
      end

      it 'should answer an empty string when there is no keychain at all' do
        allow(Security::Keychain).to receive(:default_keychain).and_raise(Security::Error.new(50, "security: SecKeychainCopyDefault: A default keychain could not be found.\n"))
        allow(Security::Keychain).to receive(:list).with(:user).and_return([])

        expect(FastlaneCore::CertChecker.wwdr_keychain).to eq("")
      end
    end

    describe 'shell escaping' do
      let(:keychain_name) { "keychain with spaces.keychain" }

      it 'should pass keychain names with spaces as they are when checking for installation' do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return(keychain_name)
        expect(Security::Certificate).to receive(:find).with(name: anything, keychain: keychain_name).twice.and_return([])

        FastlaneCore::CertChecker.installed_wwdr_certificates
      end

      describe 'uses the correct command to import it' do
        it 'with default' do
          # We have to execute *something* using ` since otherwise we set expectations to `nil`, which is not healthy
          `ls`

          keychain = "keychain with spaces.keychain"
          cmd = %r{\Acurl -f -o (([A-Z]\:)?\/.+\.cer) https://www\.apple\.com/certificateauthority/AppleWWDRCAG6\.cer\z}
          require "open3"

          expect(Open3).to receive(:capture3).with(cmd).and_return(["", "", success_status])
          expect(Security::Certificate).to receive(:import).with(end_with(".cer"), keychain: keychain, trusted_applications: []).and_return(true)
          expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return(keychain_name)

          allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5', 'DEV-ID-G1', 'DEV-ID-G2'])
          expect(FastlaneCore::CertChecker.install_missing_wwdr_certificates).to be(1)
        end

        it 'with FASTLANE_WWDR_USE_HTTP1_AND_RETRIES feature' do
          # We have to execute *something* using ` since otherwise we set expectations to `nil`, which is not healthy
          `ls`

          stub_const('ENV', { "FASTLANE_WWDR_USE_HTTP1_AND_RETRIES" => "true" })

          keychain = "keychain with spaces.keychain"
          cmd = %r{\Acurl --http1.1 --retry 3 --retry-all-errors -f -o (([A-Z]\:)?\/.+\.cer) https://www\.apple\.com/certificateauthority/AppleWWDRCAG6\.cer\z}
          require "open3"

          expect(Open3).to receive(:capture3).with(cmd).and_return(["", "", success_status])
          expect(Security::Certificate).to receive(:import).with(end_with(".cer"), keychain: keychain, trusted_applications: []).and_return(true)
          expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return(keychain_name)

          allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5', 'DEV-ID-G1', 'DEV-ID-G2'])
          expect(FastlaneCore::CertChecker.install_missing_wwdr_certificates).to be(1)
        end
      end
    end
  end
end
