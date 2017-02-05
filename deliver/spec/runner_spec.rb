require 'deliver/runner'

describe Deliver::Runner do
  let(:runner) do
    allow(Spaceship::Tunes).to receive(:login).and_return(true)
    allow(Spaceship::Tunes).to receive(:select_team).and_return(true)
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
      app: double('app', { apple_id: 'YI8C2AS' }),
      platform: 'ios'
    }
  end

  describe :upload_binary do
    let(:transporter) { double }
    before do
      allow(FastlaneCore::ItunesTransporter).to receive(:new).and_return(transporter)
    end

    describe 'with an IPA file for iOS' do
      it 'uploads the IPA for the iOS platform' do
        expect_any_instance_of(FastlaneCore::IpaUploadPackageBuilder).to receive(:generate)
          .with(app_id: 'YI8C2AS', ipa_path: 'ACME.ipa', package_path: '/tmp', platform: 'ios')
          .and_return('path')
        expect(transporter).to receive(:upload).with('YI8C2AS', 'path').and_return(true)
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
        expect(transporter).to receive(:upload).with('YI8C2AS', 'path').and_return(true)
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
        expect(transporter).to receive(:upload).with('YI8C2AS', 'path').and_return(true)
        runner.upload_binary
      end
    end
  end
end
