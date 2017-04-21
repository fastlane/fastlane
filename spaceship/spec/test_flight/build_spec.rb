require 'spec_helper'
require_relative '../mock_servers'

describe Spaceship::TestFlight::Build do

  before do
    Spaceship::TestFlight::Build.client = Spaceship::TestFlight::Client.new(current_team_id: 1)
  end

  context '.find' do
    before do
      MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/builds/:build_id') do
        {
          id: 456,
          bundleId: 'com.test.derp',
          trainVersion: '1.0',
        }
      end
    end

    it 'finds a build by a build_id' do
      build = Spaceship::TestFlight::Build.find(app_id: 123, build_id: 456)
      expect(build).to be_instance_of(Spaceship::TestFlight::Build)
      expect(build.id).to eq(456)
    end
  end

  context 'collections' do

  end

  context 'instances' do
    context '#save!' do
      it 'saves via the client' do

      end
    end
  end

end
