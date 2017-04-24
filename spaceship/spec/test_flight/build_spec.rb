require 'spec_helper'
require_relative '../mock_servers'

describe Spaceship::TestFlight::Build do

  before do
    # Use a simple client for all data models
    Spaceship::TestFlight::Build.client = Spaceship::TestFlight::Client.new(current_team_id: 1)
    Spaceship::TestFlight::BuildTrains.client = Spaceship::TestFlight::Client.new(current_team_id: 1)
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

    it 'returns nil when the build cannot be found' do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/builds/:build_id') do
        halt 404
      end

      Spaceship::TestFlight::Build.find(app_id: 123, build_id: 456)
      # TODO: should we return nil or raise an exception?
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
              trainVersion: '1.0'
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
              trainVersion: '1.1'
            }
          ],
          error: nil
        }
      end
    end

    context '.all' do
      it 'contains all of the builds across all build trains' do
        builds = Spaceship::TestFlight::Build.all(app_id: 10, platform: 'ios')
        expect(builds.size).to eq(2)
        expect(builds.sample).to be_instance_of(Spaceship::TestFlight::Build)
        expect(builds.map(&:train_version)).to eq(['1.0', '1.1'])
      end
    end
  end

  context 'instances' do
    let(:build) { Spaceship::TestFlight::Build.find(app_id: 'some-app-id', build_id: 'some-build-id')  }

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

    context 'lazy loaded attributes' do
      it ''
    end

    context '#save!' do
      it 'saves via the client' do

      end
    end
  end

end
