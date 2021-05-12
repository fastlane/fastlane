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

    let(:options_1_0) do
      { app_id: 'some-app-id', version: '1.0', build_number: '1', platform: 'IOS' }
    end
    let(:options_1_0_0) do
      { app_id: 'some-app-id', version: '1.0.0', build_number: '1', platform: 'IOS' }
    end

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

    it 'returns a build that is still processing when return_when_build_appears is true' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([processing_build])

      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_when_build_appears: true, return_spaceship_testflight_build: false)

      expect(found_build).to eq(processing_build)
    end

    it 'returns a ready to submit build with train_version and build_version truncated' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_build])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '01.00', build_version: '01', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'waits when a build is still processing' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([processing_build])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([ready_build])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])

      expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
      expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0 - 1) for #{ready_build.platform}")
      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'waits when the build disappears' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([ready_build])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])

      expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
      expect(UI).to receive(:message).with("Waiting for the build to show up in the build list - this may take a few minutes (check your email for processing issues if this continues)")
      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'watches the latest build when no builds are processing' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([ready_build])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])

      expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

      expect(found_build).to eq(ready_build)
    end

    it 'raises error when multiple builds found' do
      builds = [ready_build, ready_build]

      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return(builds)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])

      expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
      expect(UI).to receive(:message).with("Waiting for the build to show up in the build list - this may take a few minutes (check your email for processing issues if this continues)")

      error_builds = builds.map { |b| "#{b.app_version}(#{b.version}) for #{b.platform} - #{b.processing_state}" }.join("\n")

      expect do
        FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)
      end.to raise_error("FastlaneCore::BuildWatcher found more than 1 matching build: \n#{error_builds}")
    end

    it 'sleeps 10 seconds by default' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([processing_build])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep).with(10)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([ready_build])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])

      allow(UI).to receive(:message)
      allow(UI).to receive(:success)
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)
    end

    it 'sleeps for the amount of time specified in poll_interval' do
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([processing_build])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])
      expect(FastlaneCore::BuildWatcher).to receive(:sleep).with(123)
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([ready_build])
      expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])

      allow(UI).to receive(:message)
      allow(UI).to receive(:success)
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', poll_interval: 123, return_spaceship_testflight_build: false)
    end

    describe 'alternate versions' do
      describe '1.0 with 1.0.0 alternate' do
        it 'specific version returns one with alternate returns none' do
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([processing_build])
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])
          expect(FastlaneCore::BuildWatcher).to receive(:sleep)
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([ready_build])
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])

          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
          expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0 - 1) for #{ready_build.platform}")
          expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
          found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

          expect(found_build).to eq(ready_build)
        end

        it 'specific version returns non but alternate returns one' do
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([])
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([processing_build])
          expect(FastlaneCore::BuildWatcher).to receive(:sleep)
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([])
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([ready_build])

          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
          expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0 - 1) for #{ready_build.platform}")
          expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
          found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0', build_version: '1', return_spaceship_testflight_build: false)

          expect(found_build).to eq(ready_build)
        end
      end

      describe '1.0.0 with 1.0 alternate' do
        let(:processing_build) do
          double(
            app_version: "1.0.0",
            version: "1",
            processed?: false,
            platform: 'IOS',
            processing_state: 'PROCESSING'
          )
        end
        let(:ready_build) do
          double(
            app_version: "1.0.0",
            version: "1",
            processed?: true,
            platform: 'IOS',
            processing_state: 'VALID'
          )
        end

        it 'specific version returns one with alternate returns none' do
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([processing_build])
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([])
          expect(FastlaneCore::BuildWatcher).to receive(:sleep)
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([ready_build])
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([])

          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
          expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0.0 - 1) for #{ready_build.platform}")
          expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")

          found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0.0', build_version: '1', return_spaceship_testflight_build: false)

          expect(found_build).to eq(ready_build)
        end

        it 'specific version returns non but alternate returns one' do
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([processing_build])
          expect(FastlaneCore::BuildWatcher).to receive(:sleep)
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_0).and_return([])
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0).and_return([ready_build])

          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
          expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0.0 - 1) for #{ready_build.platform}")
          expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")

          expect(UI).to receive(:important).with("App version is 1.0.0 but build was found while querying 1.0")
          expect(UI).to receive(:important).with("This shouldn't be an issue as Apple sees 1.0.0 and 1.0 as equal")
          expect(UI).to receive(:important).with("See docs for more info - https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/20001431-102364")

          found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0.0', build_version: '1', return_spaceship_testflight_build: false)

          expect(found_build).to eq(ready_build)
        end
      end

      describe '1.0.1 with no alternate versions' do
        let(:processing_build) do
          double(
            app_version: "1.0.1",
            version: "1",
            processed?: false,
            platform: 'IOS',
            processing_state: 'PROCESSING'
          )
        end
        let(:ready_build) do
          double(
            app_version: "1.0.1",
            version: "1",
            processed?: true,
            platform: 'IOS',
            processing_state: 'VALID'
          )
        end
        let(:options_1_0_1) do
          { app_id: 'some-app-id', version: '1.0.1', build_number: '1', platform: 'IOS' }
        end

        it 'specific version returns one with alternate returns none' do
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_1).and_return([processing_build])
          expect(FastlaneCore::BuildWatcher).to receive(:sleep)
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_1).and_return([ready_build])

          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
          expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0.1 - 1) for #{ready_build.platform}")
          expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
          found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0.1', build_version: '1', return_spaceship_testflight_build: false)

          expect(found_build).to eq(ready_build)
        end

        it 'specific version returns non but alternate returns one' do
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_1).and_return([processing_build])
          expect(FastlaneCore::BuildWatcher).to receive(:sleep)
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_1_0_1).and_return([ready_build])

          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: #{ready_build.app_version}, build_version: #{ready_build.version}, platform: #{ready_build.platform}")
          expect(UI).to receive(:message).with("Waiting for App Store Connect to finish processing the new build (1.0.1 - 1) for #{ready_build.platform}")
          expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")
          found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, train_version: '1.0.1', build_version: '1', return_spaceship_testflight_build: false)

          expect(found_build).to eq(ready_build)
        end
      end
    end

    describe 'no app version to watch' do
      describe 'with no build number' do
        let(:options_no_version) do
          { app_id: 'some-app-id', version: nil, build_number: nil, platform: 'IOS' }
        end

        it 'returns a ready to submit build when select_latest is true' do
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_no_version).and_return([ready_build])

          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: , build_version: , platform: #{ready_build.platform}")
          expect(UI).to receive(:message).with("Searching for the latest build")
          expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")

          expect(FastlaneCore::BuildWatcher).to_not(receive(:sleep))
          found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, poll_interval: 0, select_latest: true, return_spaceship_testflight_build: false)

          expect(found_build).to eq(ready_build)
        end

        it 'raises error when select_latest is false' do
          expect(Spaceship::ConnectAPI::Build).to_not(receive(:all))

          expect(UI).to_not(receive(:important))
          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: , build_version: #{ready_build.version}, platform: #{ready_build.platform}")

          expect do
            FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, build_version: '1', poll_interval: 0, select_latest: false, return_spaceship_testflight_build: false)
          end.to raise_error("FastlaneCore::BuildWatcher has no app version to watch")
        end
      end

      describe 'with build number' do
        let(:options_no_version_but_with_build_number) do
          { app_id: 'some-app-id', version: nil, build_number: '1', platform: 'IOS' }
        end

        it 'returns a ready to submit build when select_latest is true' do
          expect(Spaceship::ConnectAPI::Build).to receive(:all).with(options_no_version_but_with_build_number).and_return([ready_build])

          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: , build_version: #{ready_build.version}, platform: #{ready_build.platform}")
          expect(UI).to receive(:message).with("Watched build version should not be present when there is no app version to watch")
          expect(UI).to receive(:message).with("Searching for the latest build")
          expect(UI).to receive(:success).with("Successfully finished processing the build #{ready_build.app_version} - #{ready_build.version} for #{ready_build.platform}")

          expect(FastlaneCore::BuildWatcher).to_not(receive(:sleep))
          found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, build_version: '1', poll_interval: 2, select_latest: true, return_spaceship_testflight_build: false)

          expect(found_build).to eq(ready_build)
        end

        it 'raises error when select_latest is false' do
          expect(Spaceship::ConnectAPI::Build).to_not(receive(:all))

          expect(UI).to_not(receive(:important))
          expect(UI).to receive(:message).with("Waiting for processing on... app_id: some-app-id, app_version: , build_version: #{ready_build.version}, platform: #{ready_build.platform}")

          expect(FastlaneCore::BuildWatcher).to_not(receive(:sleep))

          expect do
            FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, build_version: '1', poll_interval: 0, select_latest: false, return_spaceship_testflight_build: false)
          end.to raise_error("FastlaneCore::BuildWatcher has no app version to watch")
        end
      end
    end
  end
end
