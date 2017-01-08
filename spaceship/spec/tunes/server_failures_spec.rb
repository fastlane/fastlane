describe Spaceship::TunesClient do
  describe "Random Server Failures" do
    before { Spaceship::Tunes.login }
    let(:client) { Spaceship::Application.client }
    let(:app) { Spaceship::Application.all.first }

    describe "#build_trains failing" do
      it "automatically re-tries the request when getting a ITC.response.error.OPERATION_FAILED when receive build trains" do
        # Ensuring the fix for https://github.com/fastlane/fastlane/issues/6419

        # First, stub a failing request
        stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/?testingType=internal").
          to_return(status: 200, body: TunesStubbing.itc_read_fixture_file('build_trains_operation_failed.json'), headers: { 'Content-Type' => 'application/json' }).times(2).
          then.to_return(status: 200, body: TunesStubbing.itc_read_fixture_file('build_trains.json'), headers: { 'Content-Type' => 'application/json' })

        build_trains = app.build_trains
        expect(build_trains).to be_a(Hash)
        expect(build_trains.values.first).to be_a(Spaceship::Tunes::BuildTrain)
      end

      it "raises an exception after retrying a failed request multiple times" do
        stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/?testingType=internal").
          to_return(status: 200, body: TunesStubbing.itc_read_fixture_file('build_trains_operation_failed.json'), headers: { 'Content-Type' => 'application/json' })

        error_message = 'Temporary iTunes Connect error: {"data"=>nil, "messages"=>{"warn"=>nil, "error"=>["ITC.response.error.OPERATION_FAILED"], "info"=>nil}, "statusCode"=>"ERROR"}'

        expect do
          build_trains = app.build_trains
        end.to raise_exception(Spaceship::Client::UnexpectedResponse, error_message)
      end
    end
  end
end
