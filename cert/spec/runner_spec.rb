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

    describe "Pass Type ID certificates" do
      before do
        allow(Spaceship::ConnectAPI).to receive(:login).and_return(nil)
        allow(Spaceship::ConnectAPI).to receive(:client).and_return("client")
        allow(Spaceship::ConnectAPI.client).to receive(:in_house?).and_return(false)

        options = { type: "pass_type_id", identifier: "pass.com.example.mypass" }
        Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options)
      end

      it "requests PASS_TYPE_ID certificates" do
        expect(Cert::Runner.new.certificate_types).to eq([Spaceship::ConnectAPI::Certificate::CertificateType::PASS_TYPE_ID])
      end

      it "only considers certificates of the requested pass type identifier" do
        matching_cert = double(display_name: "pass.com.example.mypass")
        other_cert = double(display_name: "pass.com.example.otherpass")
        allow(Spaceship::ConnectAPI::Certificate).to receive(:all).and_return([other_cert, matching_cert])

        expect(Cert::Runner.new.certificates).to eq([matching_cert])
      end

      it "resolves the pass type id from the identifier" do
        pass_type = double(identifier: "pass.com.example.mypass", id: "4B77K434AB")
        allow(Spaceship::ConnectAPI::PassTypeId).to receive(:all).and_return([pass_type])

        expect(Cert::Runner.new.pass_type_id).to eq("4B77K434AB")
      end

      it "shows an error when the pass type id is not registered on the portal" do
        allow(Spaceship::ConnectAPI::PassTypeId).to receive(:all).and_return([])

        expect do
          Cert::Runner.new.pass_type_id
        end.to raise_error("Couldn't find Pass Type ID 'pass.com.example.mypass' on the Developer Portal")
      end

      it "requires a identifier when running with type pass_type_id" do
        Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, { type: "pass_type_id" })

        expect do
          Cert::Runner.new.run
        end.to raise_error("You need to provide an `identifier` (e.g. 'pass.com.example.mypass') when creating a Pass Type ID certificate")
      end

      it "requires the identifier to start with 'pass.' when running with type pass_type_id" do
        Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, { type: "pass_type_id", identifier: "com.example.app" })

        expect do
          Cert::Runner.new.run
        end.to raise_error("Pass Type ID identifiers need to start with 'pass.' (e.g. 'pass.com.example.mypass'), got: com.example.app")
      end
    end
  end
end
