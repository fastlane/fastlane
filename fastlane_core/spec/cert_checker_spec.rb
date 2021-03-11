describe FastlaneCore do
  describe FastlaneCore::CertChecker do
    describe '#installed_identies' do
      it 'should print an error when no local code signing identities are found' do
        allow(FastlaneCore::CertChecker).to receive(:wwdr_certificates_installed?).and_return(true)
        allow(FastlaneCore::CertChecker).to receive(:list_available_identities).and_return("     0 valid identities found\n")
        expect(FastlaneCore::UI).to receive(:error).with(/There are no local code signing identities found/)

        FastlaneCore::CertChecker.installed_identies
      end

      it 'should not be fooled by 10 local code signing identities available' do
        allow(FastlaneCore::CertChecker).to receive(:wwdr_certificates_installed?).and_return(true)
        allow(FastlaneCore::CertChecker).to receive(:list_available_identities).and_return("     10 valid identities found\n")
        expect(FastlaneCore::UI).not_to(receive(:error))

        FastlaneCore::CertChecker.installed_identies
      end
    end

    describe '#install_wwdr_certificates' do
      it 'should install all the official WWDR certificates' do
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with(/AppleWWDRCA/)
        expect(FastlaneCore::CertChecker).to receive(:install_wwdr_certificate).with(/AppleWWDRCAG3/)
        FastlaneCore::CertChecker.install_wwdr_certificates
      end
    end

    describe 'shell escaping' do
      let(:keychain_name) { "keychain with spaces.keychain" }
      let(:shell_escaped_name) { keychain_name.shellescape }
      let(:name_regex) { Regexp.new(Regexp.escape(shell_escaped_name)) }

      it 'should shell escape keychain names when checking for installation' do
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return(keychain_name)
        expect(FastlaneCore::Helper).to receive(:backticks).with(name_regex, anything).and_return("")

        FastlaneCore::CertChecker.wwdr_certificates_installed?
      end

      it 'uses the correct command to import it' do
        # We have to execute *something* using ` since otherwise we set expectations to `nil`, which is not healthy
        `ls`

        keychain = "keychain with spaces.keychain"
        cmd = %r{curl -f -o (([A-Z]\:)?\/.+) https://developer\.apple\.com/certificationauthority/AppleWWDRCA.cer && security import \1 -k #{Regexp.escape(keychain.shellescape)}}
        require "open3"

        expect(Open3).to receive(:capture3).with(cmd).and_return("")
        expect(FastlaneCore::CertChecker).to receive(:wwdr_keychain).and_return(keychain_name)

        expect(FastlaneCore::CertChecker.install_wwdr_certificate('https://developer.apple.com/certificationauthority/AppleWWDRCA.cer')).to be(true)
      end
    end
  end
end
