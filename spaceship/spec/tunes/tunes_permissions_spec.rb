describe Spaceship::Tunes do
  describe "InsufficientPermissions" do
    before { Spaceship::Tunes.login }
    let(:app) { Spaceship::Application.all.first }

    it "raises an appropriate iTunes Connect error when user doesn't have enough permission to do something" do
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/812106519").
        to_return(status: 200, body: '{
            "data": null,
            "messages": {
              "warn": null,
              "error": ["Forbidden"],
              "info": null
            },
            "statusCode": "ERROR"
          }', headers: { 'Content-Type' => 'application/json' })

      expected_error_message = "User spaceship@krausefx.com doesn't have enough permission for the following action: update_app_version"

      e = app.edit_version
      expect(e.description["German"]).to eq("My title")
      e.description["German"] = "Something new"
      expect do
        e.save!
      end.to raise_exception(Spaceship::Client::InsufficientPermissions, expected_error_message)
    end
  end
end
