describe FastlaneCore do
  describe FastlaneCore::CertChecker do
    describe '#installed_identies' do
      it 'should print an error when no local code signing identities are found' do
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(%w[G2 G3 G4 G5 G6])
        allow(FastlaneCore::CertChecker).to receive(:list_available_identities).and_return("     0 valid identities found\n")
        expect(FastlaneCore::UI).to receive(:error).with(/There are no local code signing identities found/)

        FastlaneCore::CertChecker.installed_identies
      end

      it 'should not be fooled by 10 local code signing identities available' do
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(%w[G2 G3 G4 G5 G6])
        allow(FastlaneCore::CertChecker).to receive(:list_available_identities).and_return("     10 valid identities found\n")
        expect(FastlaneCore::UI).not_to(receive(:error))

        FastlaneCore::CertChecker.installed_identies
      end
    end

    describe '#installed_wwdr_certificates' do
      it "should return installed certificate's OrganizationalUnit" do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return('login.keychain')
        allow(FastlaneCore::Helper).to receive(:backticks).with(/security find-certificate/).and_return("-----BEGIN CERTIFICATE-----\nG6\n-----END CERTIFICATE-----\n")
        allow(FastlaneCore::Helper).to receive(:backticks).with(/openssl x509/).and_return("subject= /CN=Apple Worldwide Developer Relations Certification Authority/OU=G6/O=Apple Inc./C=US\n")
        expect(FastlaneCore::CertChecker.installed_wwdr_certificates).to eq(['G6'])
      end
    end

    describe '#install_missing_wwdr_certificates' do
      it 'should install all official WWDR certificates' do
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return([])
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G2')
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G3')
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G4')
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G5')
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G6')
        FastlaneCore::CertChecker.install_missing_wwdr_certificates
      end

      it 'should install the missing official WWDR certificate' do
        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(%w[G2 G3 G4 G5])
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with('G6')
        FastlaneCore::CertChecker.install_missing_wwdr_certificates
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

      it 'uses the correct command to import it' do
        # We have to execute *something* using ` since otherwise we set expectations to `nil`, which is not healthy
        `ls`

        keychain = "keychain with spaces.keychain"
        cmd = %r{curl -f -o (([A-Z]\:)?\/.+) https://www\.apple\.com/certificateauthority/AppleWWDRCAG6\.cer && security import \1 -k #{Regexp.escape(keychain.shellescape)}}
        require "open3"

        expect(Open3).to receive(:capture3).with(cmd).and_return("")
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return(keychain_name)

        allow(FastlaneCore::CertChecker).to receive(:installed_wwdr_certificates).and_return(%w[G2 G3 G4 G5])
        expect(FastlaneCore::CertChecker.install_missing_wwdr_certificates).to be(1)
      end
    end
  end
end
