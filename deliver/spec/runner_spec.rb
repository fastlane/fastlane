require 'deliver/runner'

class MockSession
  def teams
    [
      { 'contentProvider' => { 'contentProviderId' => 'abc', 'name' => 'A B C' } },
      { 'contentProvider' => { 'contentProviderId' => 'def', 'name' => 'D E F' } }
    ]
  end

  def team_id
    'abc'
  end

  def csrf_tokens
    nil
  end
end

class MockTransporter
  def provider_ids
    {
      'A B C' => 'abc',
      'D E F' => 'somelegacything'
    }
  end
end

describe Deliver::Runner do
  let(:runner) do
    allow(Spaceship::ConnectAPI).to receive(:login).and_return(true)
    allow(Spaceship::ConnectAPI).to receive(:select_team).and_return(true)
    mock_session = MockSession.new
    allow(Spaceship::Tunes).to receive(:client).and_return(mock_session)
    allow(Spaceship::ConnectAPI).to receive_message_chain('client.tunes_client').and_return(mock_session)
    allow_any_instance_of(Deliver::DetectValues).to receive(:run!) { |opt| opt }
    Deliver::Runner.new(options)
  end

  let(:options) do
    # A typical options hash expected from Deliver::DetectValues
    {
      username: 'bill@acme.com',
      ipa: 'ACME.ipa',
      app_identifier: 'com.acme.acme',
      app_version: '1.0.7',
      platform: 'ios'
    }
  end

  let(:fake_team_api_key_json_path) { File.absolute_path("./spaceship/spec/connect_api/fixtures/asc_key.json") }
  let(:fake_individual_api_key_json_path) { File.absolute_path("./spaceship/spec/connect_api/fixtures/asc_individual_key.json") }

  before do
    allow(Deliver).to receive(:cache).and_return({
      app: double('app', { id: 'YI8C2AS' })
    })
  end

  describe :upload_binary do
    let(:transporter) { MockTransporter.new }
    before do
      allow(FastlaneCore::ItunesTransporter).to receive(:new).and_return(transporter)
    end

    describe 'with an IPA file for iOS' do
      it 'uploads the IPA for the iOS platform' do
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', ipa_path: 'ACME.ipa', package_path: '/tmp', platform: 'ios')
          .and_return('path')
        expect(transporter).to receive(:upload).with(package_path: 'path', asset_path: 'ACME.ipa', platform: 'ios').and_return(true)
        runner.upload_binary
      end
    end

    describe 'with an IPA file for tvOS' do
      before do
        options[:platform] = 'appletvos'
      end

      it 'uploads the IPA for the tvOS platform' do
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', ipa_path: 'ACME.ipa', package_path: '/tmp', platform: 'appletvos')
          .and_return('path')
        expect(transporter).to receive(:upload).with(package_path: 'path', asset_path: 'ACME.ipa', platform: 'appletvos').and_return(true)
        runner.upload_binary
      end
    end

    describe 'with an IPA file for visionOS' do
      before do
        options[:platform] = 'xros'
      end

      it 'uploads the IPA for the visionOS platform' do
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', ipa_path: 'ACME.ipa', package_path: '/tmp', platform: 'xros')
          .and_return('path')
        expect(transporter).to receive(:upload).with(package_path: 'path', asset_path: 'ACME.ipa', platform: 'xros').and_return(true)
        runner.upload_binary
      end
    end

    describe 'with a PKG file for macOS' do
      before do
        options[:platform] = 'osx'
        options[:pkg] = 'ACME.pkg'
        options[:ipa] = nil
      end

      it 'uploads the PKG for the macOS platform' do
        expect_any_instance_of(FastlaneCore::PkgUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', pkg_path: 'ACME.pkg', package_path: '/tmp', platform: 'osx')
          .and_return('path')
        expect(transporter).to receive(:upload).with(package_path: 'path', asset_path: 'ACME.pkg', platform: 'osx').and_return(true)
        runner.upload_binary
      end
    end

    describe 'with Team API Key' do
      before do
        options[:api_key] = JSON.load_file(fake_team_api_key_json_path, symbolize_names: true)
      end

      it 'initializes transporter with API key' do
        token = instance_double(Spaceship::ConnectAPI::Token, {
          text: 'API_TOKEN',
          expired?: false
        })
        allow(Spaceship::ConnectAPI).to receive(:token).and_return(token)
        allow(Spaceship::ConnectAPI).to receive(:token=)
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate).and_return('path')
        expect(FastlaneCore::ItunesTransporter).to receive(:new)
          .with(
            nil,
            nil,
            false,
            nil,
            'API_TOKEN',
            {
              altool_compatible_command: true,
              api_key: options[:api_key],
            }
          )
          .and_return(transporter)
        expect(transporter).to receive(:upload).with(package_path: 'path', asset_path: 'ACME.ipa', platform: 'ios').and_return(true)
        runner.upload_binary
      end
    end

    describe 'with Individual API Key' do
      before do
        options[:api_key] = JSON.load_file(fake_individual_api_key_json_path, symbolize_names: true)
      end

      it 'initializes transporter with username' do
        token = instance_double(Spaceship::ConnectAPI::Token, {
          text: 'API_TOKEN',
          expired?: false
        })
        allow(Spaceship::ConnectAPI).to receive(:token).and_return(token)
        allow(Spaceship::ConnectAPI).to receive(:token=)
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate).and_return('path')
        expect(FastlaneCore::ItunesTransporter).to receive(:new)
          .with(
            'bill@acme.com',
            nil,
            false,
            nil,
            {
              altool_compatible_command: true,
              api_key: nil,
            }
          )
          .and_return(transporter)
        expect(transporter).to receive(:upload).and_return(true)
        runner.upload_binary
      end
    end
  end

  describe :verify_binary do
    let(:transporter) { MockTransporter.new }
    before do
      allow(FastlaneCore::ItunesTransporter).to receive(:new).and_return(transporter)
    end

    describe 'with an IPA file for iOS' do
      it 'verifies the IPA for the iOS platform' do
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', ipa_path: 'ACME.ipa', package_path: '/tmp', platform: 'ios')
          .and_return('path')
        expect(transporter).to receive(:verify).with(asset_path: "ACME.ipa", package_path: 'path', platform: "ios").and_return(true)
        runner.verify_binary
      end
    end

    describe 'with an IPA file for tvOS' do
      before do
        options[:platform] = 'appletvos'
      end

      it 'verifies the IPA for the tvOS platform' do
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', ipa_path: 'ACME.ipa', package_path: '/tmp', platform: 'appletvos')
          .and_return('path')
        expect(transporter).to receive(:verify).with(asset_path: "ACME.ipa", package_path: 'path', platform: "appletvos").and_return(true)
        runner.verify_binary
      end
    end

    describe 'with an IPA file for visionOS' do
      before do
        options[:platform] = 'xros'
      end

      it 'verifies the IPA for the visionOS platform' do
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', ipa_path: 'ACME.ipa', package_path: '/tmp', platform: 'xros')
          .and_return('path')
        expect(transporter).to receive(:verify).with(asset_path: "ACME.ipa", package_path: 'path', platform: "xros").and_return(true)
        runner.verify_binary
      end
    end

    describe 'with a PKG file for macOS' do
      before do
        options[:platform] = 'osx'
        options[:pkg] = 'ACME.pkg'
        options[:ipa] = nil
      end

      it 'verifies the PKG for the macOS platform' do
        expect_any_instance_of(FastlaneCore::PkgUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', pkg_path: 'ACME.pkg', package_path: '/tmp', platform: 'osx')
          .and_return('path')
        expect(transporter).to receive(:verify).with(asset_path: "ACME.pkg", package_path: 'path', platform: "osx").and_return(true)
        runner.verify_binary
      end
    end

    describe 'with Team API Key' do
      before do
        options[:api_key] = JSON.load_file(fake_team_api_key_json_path, symbolize_names: true)
      end

      it 'initializes transporter with API Key' do
        token = instance_double(Spaceship::ConnectAPI::Token, {
          text: 'API_TOKEN',
          expired?: false
        })
        allow(Spaceship::ConnectAPI).to receive(:token).and_return(token)
        allow(Spaceship::ConnectAPI).to receive(:token=)
        allow_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate).and_return('path')
        expect(FastlaneCore::ItunesTransporter).to receive(:new)
          .with(
            nil,
            nil,
            false,
            nil,
            'API_TOKEN',
            {
              altool_compatible_command: true,
              api_key: options[:api_key],
            }
          )
          .and_return(transporter)
        expect(transporter).to receive(:verify).and_return(true)
        runner.verify_binary
      end
    end

    describe 'with Individual API Key' do
      before do
        options[:api_key] = JSON.load_file(fake_individual_api_key_json_path, symbolize_names: true)
      end

      it 'initializes transporter with username' do
        token = instance_double(Spaceship::ConnectAPI::Token, {
          text: 'API_TOKEN',
          expired?: false
        })
        allow(Spaceship::ConnectAPI).to receive(:token).and_return(token)
        allow(Spaceship::ConnectAPI).to receive(:token=)
        allow_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate).and_return('path')
        expect(FastlaneCore::ItunesTransporter).to receive(:new)
          .with(
            'bill@acme.com',
            nil,
            false,
            nil,
            {
              altool_compatible_command: true,
              api_key: nil,
            }
          )
          .and_return(transporter)
        expect(transporter).to receive(:verify).and_return(true)
        runner.verify_binary
      end
    end
  end
end
