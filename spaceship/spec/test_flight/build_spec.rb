require 'spec_helper'
require_relative '../mock_servers'

describe Spaceship::TestFlight::Build do

  before do
    Spaceship::TestFlight::Build.client = Spaceship::TestFlight::Client.new(current_team_id: 1)
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
    context '.all' do
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

    context '#save!' do
      it 'saves via the client' do

      end
    end
  end

end
