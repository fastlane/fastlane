require 'spec_helper'
require_relative '../mock_servers'

describe Spaceship::TestFlight::BuildTrains do
  before do
    Spaceship::TestFlight::Base.client = Spaceship::TestFlight::Client.new(current_team_id: 1)
    MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/platforms/ios/trains') do
      {
        data: ['1.0', '1.1'],
        error: nil
      }
    end
    MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/platforms/ios/trains/1.0/builds') do
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
    MockAPI::TestFlightServer.get('/testflight/v2/providers/:team_id/apps/:app_id/platforms/ios/trains/1.1/builds') do
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
    it 'returns versions and builds' do
      build_trains = Spaceship::TestFlight::BuildTrains.all(app_id: 'some-app-id', platform: 'ios')
      expect(build_trains['1.0'].size).to eq(1)
      expect(build_trains['1.1'].size).to eq(2)
      expect(build_trains.values.flatten.size).to eq(3)
    end
  end
end
