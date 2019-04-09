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
    let(:ready_build) do
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
      allow(Spaceship::ConnectAPI::Base).to receive(:client).and_return(mock_base_api_client)
    end

    #    it 'returns an already-active build' do
    #      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([])
    #      expect(Spaceship::TestFlight::Build).to receive(:all).and_return([active_build])
    #
    #      expect(UI).to receive(:success).with("Build #{active_build.train_version} - #{active_build.build_version} is already being tested")
    #      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')
    #
    #      expect(found_build).to eq(active_build)
    #    end

    it 'returns a ready to submit build' do
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([])
      expect(Spaceship::TestFlight::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.train_version} - #{ready_build.build_version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')

      expect(found_build).to eq(ready_build)
    end

    #    it 'returns a export-compliance-missing build' do
    #      expect(Spaceship::TestFlight::Build).to receive(:all_processing_builds).and_return([])
    #      expect(Spaceship::TestFlight::Build).to receive(:latest).and_return(export_compliance_required_build)
    #      expect(Spaceship::TestFlight::Build).to receive(:builds_for_train).and_return([export_compliance_required_build])
    #
    #      expect(UI).to receive(:success).with("Successfully finished processing the build #{export_compliance_required_build.train_version} - #{export_compliance_required_build.build_version}")
    #      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')
    #
    #      expect(found_build).to eq(export_compliance_required_build)
    #    end

    #    it 'returns an review rejected build' do
    #      expect(Spaceship::TestFlight::Build).to receive(:all_processing_builds).and_return([])
    #      expect(Spaceship::TestFlight::Build).to receive(:latest).and_return(export_compliance_required_build)
    #      expect(Spaceship::TestFlight::Build).to receive(:builds_for_train).and_return([review_rejected_build])
    #
    #      expect(UI).to receive(:success).with("Successfully finished processing the build #{review_rejected_build.train_version} - #{review_rejected_build.build_version}")
    #      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')
    #
    #      expect(found_build).to eq(review_rejected_build)
    #    end

    let(:build_delivery) do
      {
        "attributes" => {
          "cfBundleShortVersionString" => "1.0",
          "cfBundleVersion" => "1"
        }
      }
    end

    it 'waits when a build is still processing' do
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([build_delivery])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([])
      expect(Spaceship::TestFlight::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0 - 1)")
      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.train_version} - #{ready_build.build_version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')

      expect(found_build).to eq(ready_build)
    end

    it 'waits when the build disappears' do
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([])
      expect(Spaceship::TestFlight::Build).to receive(:all).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([])
      expect(Spaceship::TestFlight::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:message).with("Build doesn't show up in the build list anymore, waiting for it to appear again (check your email for processing issues if this continues)")
      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.train_version} - #{ready_build.build_version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')

      expect(found_build).to eq(ready_build)
    end

    #    it 'watches the latest build when more than one build is processing' do
    #      expect(Spaceship::TestFlight::Build).to receive(:all_processing_builds).and_return([processing_build, old_processing_build])
    #      # Mock `:builds_for_train` to return a build in the ready state because this will terminate the wait loop.
    #      # Note that ready_build and processing_build have same build train and build number.
    #      expect(Spaceship::TestFlight::Build).to receive(:builds_for_train).and_return([ready_build])
    #
    #      expect(UI).to_not(receive(:important).with("Started watching build #{ready_build.train_version} - #{ready_build.build_version} but expected 1.0 - 0"))
    #      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.train_version} - #{ready_build.build_version}")
    #      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')
    #
    #      expect(found_build).to eq(ready_build)
    #    end

    it 'watches the latest build when no builds are processing' do
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([])
      expect(Spaceship::TestFlight::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.train_version} - #{ready_build.build_version}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')

      expect(found_build).to eq(ready_build)
    end

    #    it 'crashes if it cannot find a build to watch' do
    #      expect(Spaceship::TestFlight::Build).to receive(:all_processing_builds).and_return([])
    #      expect(Spaceship::TestFlight::Build).to receive(:latest).and_return(nil)
    #
    #      expect(UI).to receive(:crash!).with("Could not find a build for app: some-app-id on platform: ios").and_call_original
    #      expect { FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1') }.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    #    end

    it 'sleeps 10 seconds by default' do
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([build_delivery])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep).with(10)
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([])
      expect(Spaceship::TestFlight::Build).to receive(:all).and_return([ready_build])

      allow(UI).to receive(:message)
      allow(UI).to receive(:success)
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1')
    end

    it 'sleeps for the amount of time specified in poll_interval' do
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([build_delivery])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep).with(123)
      expect(mock_base_api_client).to receive(:get_build_deliveries).and_return([])
      expect(Spaceship::TestFlight::Build).to receive(:all).and_return([ready_build])

      allow(UI).to receive(:message)
      allow(UI).to receive(:success)
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', poll_interval: 123)
    end
  end
end
