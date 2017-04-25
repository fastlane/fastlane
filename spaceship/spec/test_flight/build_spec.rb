require 'spec_helper'
require_relative '../mock_servers'

describe Spaceship::TestFlight::Build do

  before do
    # Use a simple client for all data models
    Spaceship::TestFlight::Base.client = Spaceship::TestFlight::Client.new(current_team_id: 1)
  end

  context '.find' do
    it 'finds a build by a build_id' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/builds/:build_id') do
        {
          id: 456,
          bundleId: 'com.foo.bar',
          trainVersion: '1.0',
        }
      end

      build = Spaceship::TestFlight::Build.find(app_id: 123, build_id: 456)
      expect(build).to be_instance_of(Spaceship::TestFlight::Build)
      expect(build.id).to eq(456)
      expect(build.bundle_id).to eq('com.foo.bar')
    end

    it 'returns raises when the build cannot be found' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/builds/:build_id') do
        halt 404
      end

      expect {
        Spaceship::TestFlight::Build.find(app_id: 123, build_id: 456)
      }.to raise_error(Spaceship::Client::UnexpectedResponse)
    end
  end

  context 'collections' do
    before do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/10/platforms/ios/trains') do
        {
          data: ['1.0', '1.1'],
          error: nil
        }
      end
      MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/10/platforms/ios/trains/1.0/builds') do
        {
          data: [
            {
              id: 1,
              appAdamId: 10,
              trainVersion: '1.0',
              uploadDate: '2017-01-01T12:00:00.000+0000',
              externalState: 'testflight.build.state.export.compliance.missing',
            }
          ],
          error: nil
        }
      end
      MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/10/platforms/ios/trains/1.1/builds') do
        {
          data: [
            {
              id: 2,
              appAdamId: 10,
              trainVersion: '1.1',
              uploadDate: '2017-01-02T12:00:00.000+0000',
              externalState: 'testflight.build.state.submit.ready',
            },
            {
              id: 3,
              appAdamId: 10,
              trainVersion: '1.1',
              uploadDate: '2017-01-03T12:00:00.000+0000',
              externalState: 'testflight.build.state.processing',
            }
          ],
          error: nil
        }
      end
    end

    context '.all' do
      it 'contains all of the builds across all build trains' do
        builds = Spaceship::TestFlight::Build.all(app_id: 10, platform: 'ios')
        expect(builds.size).to eq(3)
        expect(builds.sample).to be_instance_of(Spaceship::TestFlight::Build)
        expect(builds.map(&:train_version).uniq).to eq(['1.0', '1.1'])
      end
    end

    context '.builds_for_train' do
      it 'returns the builds for a given train version' do
        builds = Spaceship::TestFlight::Build.builds_for_train(app_id: 10, platform: 'ios', train_version: '1.0')
        expect(builds.size).to eq(1)
        expect(builds.map(&:train_version)).to eq(['1.0'])
      end
    end

    context '.all_processing_builds' do
      it 'returns a collection of builds that are processing' do
        builds = Spaceship::TestFlight::Build.all_processing_builds(app_id: 10, platform: 'ios')
        expect(builds.size).to eq(1)
        expect(builds.sample.id).to eq(3)
      end
    end

    context '.latest' do
      it 'returns the latest build across all build trains' do
        latest_build = Spaceship::TestFlight::Build.latest(app_id: 10, platform: 'ios')
        expect(latest_build.upload_date).to eq(Time.utc(2017,1,3,12))
      end
    end
  end

  context 'instances' do
    let(:build) { Spaceship::TestFlight::Build.find(app_id: 'some-app-id', build_id: 'some-build-id')  }
    before do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/builds/:build_id') do
        {
          id: 'some-build-id',
          appAdamId: 'some-app-id',
          testInfo: [
            {
              locale: 'en-US',
              description: 'test info',
              feedbackEmail: 'email@example.com',
              whatsNew: 'this is new!',
            }
          ]
        }
      end
    end

    it 'reloads a build' do
      build = Spaceship::TestFlight::Build.new
      build.id = 1
      build.app_id = 2
      expect(build.client).to receive(:get_build).with(app_id: 2, build_id: 1).and_return({'bundleId' => 'reloaded'})
      build.reload
      expect(build.bundle_id).to eq('reloaded')
    end

    context '#ready_to_submit?' do
      it 'is ready to submit' do
        MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/builds/:build_id') do
          {
            'externalState': 'testflight.build.state.submit.ready'
          }
        end
        expect(build).to be_ready_to_submit
      end
    end

    context '#upload_date' do
      it 'parses the string value' do
        expect(build.upload_date).to be_instance_of(Time)
      end
    end

    context 'lazy loading attribute' do
      it 'loads TestInfo' do
        build = Spaceship::TestFlight::Build.new('bundleId' => 1, 'appAdamId' => 1)
        expect(build).to receive(:reload).once
        expect(build.test_info).to be_instance_of(Spaceship::TestFlight::TestInfo)
      end
      it 'loads BetaReviewInfo' do
        build = Spaceship::TestFlight::Build.new('bundleId' => 1, 'appAdamId' => 1)
        expect(build).to receive(:reload).once
        expect(build.test_info).to be_instance_of(Spaceship::TestFlight::BetaReviewInfo)
      end
      it 'loads ExportCompliance' do
        build = Spaceship::TestFlight::Build.new('bundleId' => 1, 'appAdamId' => 1)
        expect(build).to receive(:reload).once
        expect(build.test_info).to be_instance_of(Spaceship::TestFlight::ExportCompliance)
      end
    end

    context '#save!' do
      it 'saves via the client' do
        expect(build.client).to receive(:put_build).with(app_id: 'some-app-id', build_id: 'some-build-id', build: instance_of(Spaceship::TestFlight::Build))
        build.test_info.whats_new = 'changes!'
        build.save!
      end
    end
  end
end
