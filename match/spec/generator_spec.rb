describe Match::Generator do
  describe 'calling through' do
    describe 'cert' do
      require 'cert'
      let(:fake_runner) { double }
      let(:common_config_hash) {
        {
          development: true,
          output_path: 'workspace/certs/development',
          force: true,
          username: 'username',
          team_id: 'team_id',
          platform: "ios",
          filename: nil,
          team_name: nil
        }
      }
      let(:params) {
        {
          type: 'development',
          workspace: 'workspace',
          username: 'username',
          team_id: 'team_id',
          keychain_name: 'login.keychain',
          keychain_password: 'password'
        }
      }
      let(:config) {
        FastlaneCore::Configuration.create(
          Cert::Options.available_options,
          common_config_hash.merge(keychain_config_hash)
        )
      }

      before do
        allow(FastlaneCore::Helper).to receive(:mac?).and_return(is_mac)
        allow(FastlaneCore::Helper).to receive(:xcode_at_least?).and_return(false)
        allow(Cert::Runner).to receive(:new).and_return(fake_runner)
        allow(fake_runner).to receive(:launch).and_return("fake_path")
        allow(File).to receive(:exist?).and_call_original
      end

      context 'on macOS' do
        let(:is_mac) { true }
        let(:keychain_config_hash) {
          {
            keychain_path: FastlaneCore::Helper.keychain_path("login.keychain"),
            keychain_password: 'password'
          }
        }

        it 'configures correctly' do
          expect(FastlaneCore::Helper).to receive(:keychain_path).with("login.keychain").exactly(2).times.and_return("fake_keychain_name")
          expect(File).to receive(:expand_path).with("fake_keychain_name").exactly(2).times.and_return("fake_keychain_path")
          expect(File).to receive(:exist?).with("fake_keychain_path").exactly(2).times.and_return(true)
          expect(Cert).to receive(:config=).with(a_configuration_matching(config))
          Match::Generator.generate_certificate(params, 'development', "workspace")
        end

        it 'receives keychain_path' do
          expect(FastlaneCore::Helper).to receive(:keychain_path).with("login.keychain").and_return("fake_keychain_name")
          expect(File).to receive(:expand_path).with("fake_keychain_name").and_return("fake_keychain_path")
          expect(File).to receive(:exist?).with("fake_keychain_path").and_return(true)
          Match::Generator.generate_certificate(params, 'development', "workspace")
        end
      end

      context 'on non-macOS' do
        let(:is_mac) { false }
        let(:keychain_config_hash) {
          {
            keychain_path: nil,
            keychain_password: nil
          }
        }

        context 'with keychain_path' do
          let(:keychain_config_hash) {
            { keychain_path: "fake_keychain_path", keychain_password: "password" }
          }
          it 'raises an error' do
            expect {
              config
            }.to raise_error(FastlaneCore::Interface::FastlaneError, "Keychain is not supported on platforms other than macOS")
          end
        end

        context 'without keychain_path' do
          it 'configures correctly' do
            expect(FastlaneCore::Helper).not_to receive(:keychain_path)
            expect(File).not_to receive(:expand_path)
            expect(Cert).to receive(:config=).with(a_configuration_matching(config))
            Match::Generator.generate_certificate(params, 'development', "workspace")
          end

          it 'does not receive keychain_path' do
            expect(FastlaneCore::Helper).not_to receive(:keychain_path)
            expect(File).not_to receive(:expand_path)
            Match::Generator.generate_certificate(params, 'development', "workspace")
          end
        end
      end
    end

    describe 'sigh' do
      let(:config) {
        FastlaneCore::Configuration.create(Sigh::Options.available_options, {
          app_identifier: 'app_identifier',
          development: true,
          output_path: 'workspace/profiles/development',
          username: 'username',
          force: false,
          cert_id: 'fake_cert_id',
          provisioning_name: 'match Development app_identifier',
          ignore_profiles_with_different_name: true,
          team_id: 'team_id',
          platform: :ios,
          template_name: 'template_name',
          fail_on_name_taken: false,
          include_all_certificates: true,
        })
      }

      require 'sigh'
      it 'configures correctly for nested execution' do
        # This is the important part. We need to see the right configuration come through
        # for sigh
        expect(Sigh).to receive(:config=).with(a_configuration_matching(config))

        # This just mocks out the usual behavior of running sigh, since that's not what
        # we're testing
        allow(Sigh::Manager).to receive(:start).and_return("fake_path")

        params = {
          app_identifier: 'app_identifier',
          type: :development,
          workspace: 'workspace',
          username: 'username',
          team_id: 'team_id',
          platform: :ios,
          template_name: 'template_name',
          include_all_certificates: true,
        }
        Match::Generator.generate_provisioning_profile(params: params, prov_type: :development, certificate_id: 'fake_cert_id', app_identifier: params[:app_identifier], force: false, working_directory: "workspace")
      end
    end
  end
end
