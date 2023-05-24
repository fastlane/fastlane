describe FastlaneCore do
  describe FastlaneCore::CertChecker do
    let(:success_status) {
      class ProcessStatusMock
      end

      allow_any_instance_of(ProcessStatusMock).to receive(:success?).and_return(true)

      ProcessStatusMock.new
    }

    describe '#installed_identies' do
      it 'should print an error when no local code signing identities are found' do
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5', 'G6'])
        allow(FastlaneCore::CertChecker).to receive(:list_available_identities).and_return("     0 valid identities found\n")
        expect(FastlaneCore::UI).to receive(:error).with(/There are no local code signing identities found/)

        FastlaneCore::CertChecker.installed_identies
      end

      it 'should not be fooled by 10 local code signing identities available' do
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5', 'G6'])
        allow(FastlaneCore::CertChecker).to receive(:list_available_identities).and_return("     10 valid identities found\n")
        expect(FastlaneCore::UI).not_to(receive(:error))

        FastlaneCore::CertChecker.installed_identies
      end
    end

    describe '#installed_wwdr_certificates' do
      it "should return installed certificate's alias" do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')

        allow(FastlaneCore::Helper).to receive(:backticks).with(/security find-certificate/).and_return("-----BEGIN CERTIFICATE-----\nG6\n-----END CERTIFICATE-----\n")

        cert = OpenSSL::X509::Certificate.new
        allow(Digest::SHA256).to receive(:hexdigest).with(cert.to_der).and_return('bdd4ed6e74691f0c2bfd01be0296197af1379e0418e2d300efa9c3bef642ca30')
        allow(OpenSSL::X509::Certificate).to receive(:new).and_return(cert)

        expect(FastlaneCore::CertChecker.installed_wwdr_certificates).to eq(['G6'])
      end

      it "should return an empty array if unknown WWDR certificates are found" do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')

        allow(FastlaneCore::Helper).to receive(:backticks).with(/security find-certificate/).and_return("-----BEGIN CERTIFICATE-----\nG6\n-----END CERTIFICATE-----\n")

        cert = OpenSSL::X509::Certificate.new
        allow(OpenSSL::X509::Certificate).to receive(:new).and_return(cert)

        expect(FastlaneCore::CertChecker.installed_wwdr_certificates).to eq([])
      end
    end

    describe '#install_missing_wwdr_certificates' do

      it 'should fetch all official WWDR certificates' do
        allow_any_instance_of(File).to receive(:path).and_return('test_path')
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return([])
        expect(FastlaneCore::CertChecker).to receive(:fetch_certificate).with('G2', 'test_path')
        expect(FastlaneCore::CertChecker).to receive(:fetch_certificate).with('G3', 'test_path')
        expect(FastlaneCore::CertChecker).to receive(:fetch_certificate).with('G4', 'test_path')
        expect(FastlaneCore::CertChecker).to receive(:fetch_certificate).with('G5', 'test_path')
        expect(FastlaneCore::CertChecker).to receive(:fetch_certificate).with('G6', 'test_path')
        FastlaneCore::CertChecker.install_missing_wwdr_certificates
      end

      it 'should import all official WWDR certificates' do
        allow_any_instance_of(File).to receive(:path).and_return('test_path')
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return([])
        allow(FastlaneCore::CertChecker).to receive(:fetch_certificate).and_return(true)
        allow(FastlaneCore::CertChecker).to receive(:check_expiry).and_return(true)
        expect(FastlaneCore::CertChecker).to receive(:import_wwdr_certificate).with('test_path')
        expect(FastlaneCore::CertChecker).to receive(:import_wwdr_certificate).with('test_path')
        expect(FastlaneCore::CertChecker).to receive(:import_wwdr_certificate).with('test_path')
        expect(FastlaneCore::CertChecker).to receive(:import_wwdr_certificate).with('test_path')
        expect(FastlaneCore::CertChecker).to receive(:import_wwdr_certificate).with('test_path')
        FastlaneCore::CertChecker.install_missing_wwdr_certificates
      end

      it 'should install the missing official WWDR certificate' do
        allow_any_instance_of(File).to receive(:path).and_return('test_path')
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5'])
        expect(FastlaneCore::CertChecker).to receive(:fetch_certificate).with('G6', 'test_path')
        FastlaneCore::CertChecker.install_missing_wwdr_certificates
      end

      it 'should download the WWDR certificate from correct URL' do
        allow(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')
        allow_any_instance_of(File).to receive(:path).and_return('test_path')

        expect(Open3).to receive(:capture3).with('curl', anything, anything, anything, 'https://www.apple.com/certificateauthority/AppleWWDRCAG2.cer').and_return(["", "", success_status])
        FastlaneCore::CertChecker.fetch_certificate('G2', 'test_path')

        expect(Open3).to receive(:capture3).with('curl', anything, anything, anything, 'https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer').and_return(["", "", success_status])
        FastlaneCore::CertChecker.fetch_certificate('G3', 'test_path')

        expect(Open3).to receive(:capture3).with('curl', anything, anything, anything, 'https://www.apple.com/certificateauthority/AppleWWDRCAG4.cer').and_return(["", "", success_status])
        FastlaneCore::CertChecker.fetch_certificate('G4', 'test_path')

        expect(Open3).to receive(:capture3).with('curl', anything, anything, anything, 'https://www.apple.com/certificateauthority/AppleWWDRCAG5.cer').and_return(["", "", success_status])
        FastlaneCore::CertChecker.fetch_certificate('G5', 'test_path')

        expect(Open3).to receive(:capture3).with('curl', anything, anything, anything, 'https://www.apple.com/certificateauthority/AppleWWDRCAG6.cer').and_return(["", "", success_status])
        FastlaneCore::CertChecker.fetch_certificate('G6', 'test_path')
      end

    end

    describe 'certificate validation' do
      let(:invalid_cert) { File.expand_path("./fastlane_core/spec/fixtures/certificates/AppleWWDRCA_invalid.cer") }
      let(:valid_cert) { File.expand_path("./fastlane_core/spec/fixtures/certificates/AppleWWDRCAG6.cer") }

      it 'should not accept a certificate that has expired' do
        expect(FastlaneCore::CertChecker.check_expiry(invalid_cert)).to be(false)
      end

      it 'should accept a valid certificate' do
        expect(FastlaneCore::CertChecker.check_expiry(valid_cert)).to be(true)
      end

    end

    describe 'shell escaping' do
      let(:keychain_name) { "keychain with spaces.keychain" }
      let(:shell_escaped_name) { keychain_name.shellescape }
      let(:name_regex) { Regexp.new(Regexp.escape(shell_escaped_name)) }

      it 'should shell escape keychain names when checking for installation' do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return(keychain_name)
        expect(FastlaneCore::Helper).to receive(:backticks).with(name_regex).and_return("")

        FastlaneCore::CertChecker.installed_wwdr_certificates
      end

      describe 'uses the correct commands to import it' do
        it 'with default' do
          # We have to execute *something* using ` since otherwise we set expectations to `nil`, which is not healthy
          `ls`

          keychain = "keychain with spaces.keychain"
          require "open3"
          expect(Open3).to receive(:capture3).with('curl', '-f', '-o', anything, 'https://www.apple.com/certificateauthority/AppleWWDRCAG6.cer').and_return(["", "", success_status])
          expect(Open3).to receive(:capture3).with('security', 'verify-cert', '-c', anything).and_return(["...certificate verification successful.", ""])
          expect(Open3).to receive(:capture3).with('security', 'import', anything, anything).and_return(["", "", success_status])
          expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return(keychain_name)

          allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5'])
          expect(FastlaneCore::CertChecker.install_missing_wwdr_certificates).to be(1)
        end

        it 'with FASTLANE_WWDR_USE_HTTP1_AND_RETRIES feature' do
          # We have to execute *something* using ` since otherwise we set expectations to `nil`, which is not healthy
          `ls`

          stub_const('ENV', { "FASTLANE_WWDR_USE_HTTP1_AND_RETRIES" => "true" })

          keychain = "keychain with spaces.keychain"
          require "open3"

          expect(Open3).to receive(:capture3).with('curl', '--http1.1', '--retry', '3', '--retry-all-errors', anything, anything, anything, anything).and_return(["", "", success_status])
          expect(FastlaneCore::CertChecker).to receive(:check_expiry).and_return(true)
          expect(FastlaneCore::CertChecker).to receive(:import_wwdr_certificate).and_return(true)

          allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(['G2', 'G3', 'G4', 'G5'])
          expect(FastlaneCore::CertChecker.install_missing_wwdr_certificates).to be(1)
        end
      end
    end
  end
end
