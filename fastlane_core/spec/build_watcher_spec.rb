require 'spec_helper'

describe FastlaneCore::BuildWatcher do
  context '.wait_for_build_processing_to_be_complete' do
    let(:processing_build) do
      double(
        app_version: "1.0",
        version: "1",
        processed?: false,
        platform: 'IOS',
        processing_state: 'PROCESSING'
      )
    end
    let(:ready_build) do
      double(
        app_version: "1.0",
        version: "1",
        processed?: true,
        platform: 'IOS',
        processing_state: 'VALID'
      )
    end

    let(:mock_base_api_client) { "fake api base client" }

    before(:each) do
      allow(Spaceship::ConnectAPI::TestFlight::Client).to receive(:instance).and_return(mock_base_api_client)
    end

    it 'returns a ready to submit build' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'returns a ready to submit build with train_version and build_version truncated' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '01.00', build_version: '01', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'waits when a build is still processing' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([processing_build])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
      expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0 - 1) for #{ready_build.platform}")
      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'waits when the build disappears' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
      expect(UI).to receive(:message).with("Waiting for the build to show up in the build list - this may take a few minutes (check your email for processing issues if this continues)")
      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'watches the latest build when no builds are processing' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'raises error when multiple builds found' do
      builds = [ready_build, ready_build]

      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return(builds)

      expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
      expect(UI).to receive(:message).with("Waiting for the build to show up in the build list - this may take a few minutes (check your email for processing issues if this continues)")

      error_builds = builds.map { |b| "#{b.app_version}(#{b.version}) for #{b.platform} - #{b.processing_state}" }.join("\n")

      expect do
        FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)
      end.to raise_error("FastlaneCore::BuildWatcher found more than 1 matching build: \n#{error_builds}")
    end

    it 'sleeps 10 seconds by default' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([processing_build])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep).with(10)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      allow(UI).to receive(:message)
      allow(UI).to receive(:success)
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)
    end

    it 'sleeps for the amount of time specified in poll_interval' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([processing_build])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep).with(123)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      allow(UI).to receive(:message)
      allow(UI).to receive(:success)
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', poll_interval: 123, return_spaceship_testflight_build: false)
    end
  end
end
