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
    allow(Spaceship::Tunes).to receive(:client).and_return(MockSession.new)
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
        expect(transporter).to receive(:upload).with(package_path: 'path', asset_path: 'ACME.ipa').and_return(true)
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
        expect(transporter).to receive(:upload).with(package_path: 'path', asset_path: 'ACME.ipa').and_return(true)
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
        expect(transporter).to receive(:upload).with(package_path: 'path', asset_path: 'ACME.pkg').and_return(true)
        runner.upload_binary
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

          runner.options = { api_token: api_token }
          runner.login
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
