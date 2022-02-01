require 'tmpdir'

describe Cert do
  describe Cert::Runner do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"
    end

    xcode_versions = {
      "10" => Spaceship.certificate.production,
      "11" => Spaceship.certificate.apple_distribution
    }

    # Iterates over different Xcode versions to test different cert types
    # Xcode 10 and earlier - Spaceship.certificate.production
    # Xcode 11 and later - Spaceship.certificate.apple_distribution
    xcode_versions.each do |xcode_version, dist_cert_type|
      context "Xcode #{xcode_version}" do
        before do
          allow(FastlaneCore::Helper).to receive(:mac?).and_return(true)
          allow(FastlaneCore::Helper).to receive(:xcode_version).and_return(xcode_version)
        end

        it "Successful run" do
          certificate = stub_certificate

          allow(Spaceship::ConnectAPI).to receive(:login).and_return(nil)
          allow(Spaceship::ConnectAPI).to receive(:client).and_return("client")
          allow(Spaceship::ConnectAPI.client).to receive(:in_house?).and_return(false)

          allow(Spaceship::ConnectAPI::Certificate).to receive(:all).and_return([certificate])

          certificate_path = "#{Dir.pwd}/cert_id.cer"
          keychain_path = Dir.pwd.to_s
          expect(FastlaneCore::CertChecker).to receive(:installed?)
            .with(certificate_path, in_keychain: keychain_path)
            .twice
            .and_return(true)

          options = { keychain_path: "." }
          Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options)

          Cert::Runner.new.launch
          expect(ENV["CER_CERTIFICATE_ID"]).to eq("cert_id")
          expect(ENV["CER_FILE_PATH"]).to eq(certificate_path)
          expect(ENV["CER_KEYCHAIN_PATH"]).to eq(keychain_path)
          File.delete(ENV["CER_FILE_PATH"])
        end

        it "correctly selects expired certificates" do
          expired_cert = stub_certificate("expired_cert", false)
          good_cert = stub_certificate

          allow(Spaceship::ConnectAPI).to receive(:login).and_return(nil)
          allow(Spaceship::ConnectAPI).to receive(:client).and_return("client")
          allow(Spaceship::ConnectAPI.client).to receive(:in_house?).and_return(false)

          allow(Spaceship::ConnectAPI::Certificate).to receive(:all).and_return([expired_cert, good_cert])

          expect(Cert::Runner.new.expired_certs).to eq([expired_cert])
        end

        it "revokes expired certificates via revoke_expired sub-command" do
          expired_cert = stub_certificate("expired_cert", false)
          good_cert = stub_certificate

          allow(Spaceship::ConnectAPI).to receive(:login).and_return(nil)
          allow(Spaceship::ConnectAPI).to receive(:client).and_return("client")
          allow(Spaceship::ConnectAPI.client).to receive(:in_house?).and_return(false)
          allow(Spaceship::ConnectAPI::Certificate).to receive(:all).and_return([expired_cert, good_cert])

          allow(FastlaneCore::CertChecker).to receive(:installed?).and_return(true)

          expect(expired_cert).to receive(:delete!)
          expect(good_cert).to_not(receive(:delete!))

          Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, keychain_path: ".")
          Cert::Runner.new.revoke_expired_certs!
        end

        it "tries to revoke all expired certificates even if one has an error" do
          expired_cert_1 = stub_certificate("expired_cert_1", false)
          expired_cert_2 = stub_certificate("expired_cert_2", false)

          allow(Spaceship::ConnectAPI).to receive(:login).and_return(nil)
          allow(Spaceship::ConnectAPI).to receive(:client).and_return("client")
          allow(Spaceship::ConnectAPI.client).to receive(:in_house?).and_return(false)
          allow(Spaceship::ConnectAPI::Certificate).to receive(:all).and_return([expired_cert_1, expired_cert_2])

          allow(FastlaneCore::CertChecker).to receive(:installed?).and_return(true)

          expect(expired_cert_1).to receive(:delete!).and_raise("Boom!")
          expect(expired_cert_2).to receive(:delete!)

          Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, keychain_path: ".")
          Cert::Runner.new.revoke_expired_certs!
        end

        describe ":filename option handling" do
          filename = ""
          let(:temp) { Dir.tmpdir }
          let(:certificate) { stub_certificate }
          let(:filepath) do
            filename_ext = File.extname(filename) == ".cer" ? filename : "#{filename}.cer"
            File.extname(filename) == ".cer" ? "#{temp}/#{filename}" : "#{temp}/#{filename}.cer"
          end

          before do
            allow(Spaceship::ConnectAPI).to receive(:login).and_return(nil)
            allow(Spaceship::ConnectAPI).to receive(:client).and_return("client")
            allow(Spaceship::ConnectAPI.client).to receive(:in_house?).and_return(false)
            allow(Spaceship::ConnectAPI::Certificate).to receive(:all).and_return([certificate])

            allow(FastlaneCore::CertChecker).to receive(:installed?).and_return(true)
          end

          let(:generate) do
            options = { output_path: temp, filename: filename, keychain_path: "." }
            Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options)
            Cert::Runner.new.launch
          end

          context 'with filename flag' do
            it "can forget the file extension" do
              filename = "cert_name"
              expect(File.exist?(filepath)).to be false
              generate
              expect(File.exist?(filepath)).to be true
              File.delete(filepath)
            end

            it "can use the file extension" do
              filename = "cert_name.cer"
              expect(File.exist?(filepath)).to be false
              generate
              expect(File.exist?(filepath)).to be true
              File.delete(filepath)
            end
          end

          context 'without filename flag' do
            it "can generate certificate" do
              filename = "cert_name.cer"
              expect(File.exist?(filepath)).to be false
              generate
              expect(File.exist?(filepath)).to be true
              File.delete(filepath)
            end
          end
        end
      end
    end

    describe 'direct token text support' do
      describe '#login' do
        context 'with valid token' do
          api_token_text = 'Token.Text.JWT_content'
          in_house = false
          api_token = { in_house: in_house, token_text: api_token_text }
          fake_api_key_json_path = './spaceship/spec/connect_api/fixtures/asc_key.json'

          let(:mock_token) { Spaceship::ConnectAPI::Token.from(filepath: fake_api_key_json_path) }

          before(:each) do
            allow(Spaceship::ConnectAPI::Token).to receive(:from_token).and_return(mock_token)
            allow(Spaceship::ConnectAPI).to receive(:token=)

            options = { api_token: api_token }
            Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options)
            Cert::Runner.new.login
          end

          it 'creates token' do
            expect(Spaceship::ConnectAPI::Token).to have_received(:from_token).with(api_token)
          end

          it 'assigns token' do
            expect(Spaceship::ConnectAPI).to have_received(:token=).with(mock_token)
          end
        end
      end
    end
  end
end
