describe Match::Generator do
  describe 'calling through to other tools ' do
    it 'configures cert correctly for nested execution' do
      require 'cert'

      config = FastlaneCore::Configuration.create(Cert::Options.available_options, {
        development: true,
        output_path: 'workspace/certs/development',
        force: true,
        username: 'username',
        team_id: 'team_id',
        keychain_path: FastlaneCore::Helper.keychain_path("login.keychain")
      })

      # This is the important part. We need to see the right configuration come through
      # for cert
      expect(Cert).to receive(:config=).with(a_configuration_matching(config))

      # This just mocks out the usual behavior of running cert, since that's not what
      # we're testing
      fake_runner = "fake_runner"
      allow(Cert::Runner).to receive(:new).and_return(fake_runner)
      allow(fake_runner).to receive(:launch).and_return("fake_path")

      params = {
        type: 'development',
        workspace: 'workspace',
        username: 'username',
        team_id: 'team_id',
        keychain_name: 'login.keychain'
      }

      Match::Generator.generate_certificate(params, 'development')
    end

    it 'configures sigh correctly for nested execution' do
      require 'sigh'

      config = FastlaneCore::Configuration.create(Sigh::Options.available_options, {
        app_identifier: 'app_identifier',
        development: true,
        output_path: 'workspace/profiles/development',
        username: 'username',
        force: true,
        cert_id: 'fake_cert_id',
        provisioning_name: 'match Development app_identifier',
        ignore_profiles_with_different_name: true,
        team_id: 'team_id'
      })

      # This is the important part. We need to see the right configuration come through
      # for sigh
      expect(Sigh).to receive(:config=).with(a_configuration_matching(config))

      # This just mocks out the usual behavior of running cert, since that's not what
      # we're testing
      allow(Sigh::Manager).to receive(:start).and_return("fake_path")

      params = {
        app_identifier: 'app_identifier',
        prov_type: :development,
        workspace: 'workspace',
        username: 'username',
        team_id: 'team_id'
      }
      Match::Generator.generate_provisioning_profile(params: params, prov_type: :development, certificate_id: 'fake_cert_id', app_identifier: params[:app_identifier])
    end
  end
end
