describe Spaceship::TunesClient do
  describe "Random Server Failures", now: true do
    before { Spaceship::Tunes.login }
    let(:client) { Spaceship::Application.client }
    let(:app) { Spaceship::Application.all.first }

    it "automatically re-tries the request when getting a ITC.response.error.OPERATION_FAILED when receive build trains" do
      # Ensuring the fix for https://github.com/fastlane/fastlane/issues/6419

      # First stub a failing request
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/?testingType=internal").
         to_return(status: 200, body: TunesStubbing.itc_read_fixture_file('build_trains_operation_failed.json'), headers: { 'Content-Type' => 'application/json' }).times(10).
      then.to_return(status: 200, body: TunesStubbing.itc_read_fixture_file('build_trains.json'))

      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/?testingType=external").
         to_return(status: 200, body: TunesStubbing.itc_read_fixture_file('build_trains_operation_failed.json'), headers: { 'Content-Type' => 'application/json' })

      expect(app.build_trains).to eq({})
    end
  end
end
