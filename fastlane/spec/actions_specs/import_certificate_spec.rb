describe Fastlane do
  describe Fastlane::FastFile do
    describe "Import certificate Integration" do
      it "works with certificate and password" do
        cert_name = "test.cer"
        keychain = 'test.keychain'
        password = 'testpassword'

        keychain_path = File.expand_path(File.join('~', 'Library', 'Keychains', keychain))
        expected_command = "security import #{cert_name} -k '#{keychain_path}' -P #{password} -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"

        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with(cert_name).and_return(true)
        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: false)

        Fastlane::FastFile.new.parse("lane :test do
          import_certificate ({
            keychain_name: '#{keychain}',
            certificate_path: '#{cert_name}',
            certificate_password: '#{password}'
          })
        end").runner.execute(:test)
      end

      it "works with certificate and password that contain spaces or '\'" do
        cert_name = '\" test \".cer'
        keychain = '\" test \".keychain'
        password = '\"test password\"'

        keychain_path = File.expand_path(File.join('~', 'Library', 'Keychains', keychain))
        expected_command = "security import #{cert_name.shellescape} -k '#{keychain_path.shellescape}' -P #{password.shellescape} -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"

        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with(cert_name).and_return(true)
        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: false)

        Fastlane::FastFile.new.parse("lane :test do
          import_certificate ({
            keychain_name: '#{keychain}',
            certificate_path: '#{cert_name}',
            certificate_password: '#{password}'
          })
        end").runner.execute(:test)
      end

      it "works with a boolean for log_output" do
        cert_name = "test.cer"
        keychain = 'test.keychain'
        password = 'testpassword'

        keychain_path = File.expand_path(File.join('~', 'Library', 'Keychains', keychain))
        expected_command = "security import #{cert_name} -k '#{keychain_path}' -P #{password} -T /usr/bin/codesign -T /usr/bin/security"

        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with(cert_name).and_return(true)
        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: true)

        Fastlane::FastFile.new.parse("lane :test do
          import_certificate ({
            keychain_name: '#{keychain}',
            certificate_path: '#{cert_name}',
            certificate_password: '#{password}',
            log_output: true
          })
        end").runner.execute(:test)
      end
    end
  end
end
