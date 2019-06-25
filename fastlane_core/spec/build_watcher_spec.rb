require 'spec_helper'

describe FastlaneCore::BuildWatcher do
  context '.wait_for_build_processing_to_be_complete' do
    let(:processing_build) do
      double(
        'Processing Build',
        processed?: false,
        active?: false,
        ready_to_submit?: false,
        export_compliance_missing?: false,
        review_rejected?: false,
        train_version: '1.0',
        build_version: '1',
        upload_date: 1
      )
    end
    let(:old_processing_build) do
      double(
        'Old Processing Build',
        processed?: false,
        active?: false,
        ready_to_submit?: false,
        export_compliance_missing?: false,
        review_rejected?: false,
        train_version: '1.0',
        build_version: '0',
        upload_date: 0
      )
    end
    let(:active_build) do
      double(
        'Active Build',
        processed?: true,
        active?: true,
        ready_to_submit?: false,
        export_compliance_missing?: false,
        review_rejected?: false,
        train_version: '1.0',
        build_version: '1',
        upload_date: 1
      )
    end
    let(:testflight_ready_build) do
      double(
        'Ready Build',
        processed?: true,
        active?: false,
        ready_to_submit?: true,
        export_compliance_missing?: false,
        review_rejected?: false,
        train_version: '1.0',
        build_version: '1',
        upload_date: 1
      )
    end
    let(:ready_build) do
      double(
        app_version: "1.0",
        version: "1",
        processed?: true
      )
    end
    let(:build_delivery) do
      double(
        cf_build_short_version_string: "1.0",
        cf_build_version: "1"
      )
    end
    let(:old_ready_build) do
      double(
        'Ready Build',
        processed?: true,
        active?: false,
        ready_to_submit?: true,
        export_compliance_missing?: false,
        review_rejected?: false,
        train_version: '1.0',
        build_version: '0',
        upload_date: 1
      )
    end
    let(:export_compliance_required_build) do
      double(
        'Export Compliance Required Build',
        processed?: true,
        active?: false,
        ready_to_submit?: false,
        export_compliance_missing?: true,
        review_rejected?: false,
        train_version: '1.0',
        build_version: '1',
        upload_date: 1
      )
    end
    let(:review_rejected_build) do
      double(
        'Review Rejected Build',
        processed?: true,
        active?: false,
        ready_to_submit?: false,
        export_compliance_missing?: false,
        review_rejected?: true,
        train_version: '1.0',
        build_version: '1',
        upload_date: 1
      )
    end

    let(:mock_base_api_client) { "fake api base client" }

    before(:each) do
      allow(Spaceship::ConnectAPI::TestFlight::Client).to receive(:instance).and_return(mock_base_api_client)
    end

    it 'returns a ready to submit build' do
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'returns a ready to submit build with train_version and build_version truncated' do
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '01.00', build_version: '01', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'waits when a build is still processing' do
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([build_delivery])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0 - 1)")
      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'waits when the build disappears' do
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:message).with("Build doesn't show up in the build list anymore, waiting for it to appear again (check your email for processing issues if this continues)")
      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'watches the latest build when no builds are processing' do
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'sleeps 10 seconds by default' do
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([build_delivery])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep).with(10)
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      allow(UI).to receive(:message)
      allow(UI).to receive(:success)
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)
    end

    it 'sleeps for the amount of time specified in poll_interval' do
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([build_delivery])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep).with(123)
      expect(Spaceship::ConnectAPI::BuildDelivery).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      allow(UI).to receive(:message)
      allow(UI).to receive(:success)
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', poll_interval: 123, return_spaceship_testflight_build: false)
    end
  end
end
