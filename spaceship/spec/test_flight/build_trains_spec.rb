require 'spec_helper'
require_relative '../mock_servers'

describe Spaceship::TestFlight::BuildTrains do
  let(:mock_client) { double('MockClient') }
  before do
    allow(Spaceship::TestFlight::Base).to receive(:client).and_return(mock_client)
    allow(mock_client).to receive(:team_id).and_return('')
    mock_client_response(:get_build_trains, with: { app_id: 'some-app-id', platform: 'ios' }) do
      ['1.0', '1.1']
    end
    mock_client_response(:get_builds_for_train, with: hash_including(train_version: '1.0')) do
      [
        {
          id: 1,
          appAdamId: 10,
          trainVersion: '1.0',
          uploadDate: '2017-01-01T12:00:00.000+0000',
          externalState: 'testflight.build.state.export.compliance.missing'
        }
      ]
    end
    mock_client_response(:get_builds_for_train, with: hash_including(train_version: '1.1')) do
      [
        {
          id: 2,
          appAdamId: 10,
          trainVersion: '1.1',
          uploadDate: '2017-01-02T12:00:00.000+0000',
          externalState: 'testflight.build.state.submit.ready'
        },
        {
          id: 3,
          appAdamId: 10,
          trainVersion: '1.1',
          uploadDate: '2017-01-03T12:00:00.000+0000',
          externalState: 'testflight.build.state.processing'
        }
      ]
    end
  end

  context '.all' do
    it 'returns versions and builds' do
      #      build_trains = Spaceship::TestFlight::BuildTrains.all(app_id: 'some-app-id', platform: 'ios')
      #      expect(build_trains['1.0'].size).to eq(1)
      #      expect(build_trains['1.1'].size).to eq(2)
      #      expect(build_trains.values.flatten.size).to eq(3)
    end
  end
end
