require "produce/service"

describe Produce::Service do
  let(:fake_token) { double("connect_api_token", in_house: false) }
  let(:api_key) { { key_id: "abc", issuer_id: "def", key: "fake" } }

  def config_with(overrides = {})
    Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, {
      app_identifier: "com.example.app",
      username: "person@example.com",
      team_id: "TEAMID1234",
      team_name: "Example Team"
    }.merge(overrides))
  end

  describe "#bundle_id" do
    it "authenticates with the App Store Connect API key when configured" do
      config_with(api_key: api_key)
      allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(fake_token)
      expect(Spaceship::ConnectAPI).to receive(:client=)
      expect(Spaceship).not_to receive(:login)
      found_bundle_id = double("bundle_id")
      allow(Spaceship::ConnectAPI::BundleId).to receive(:find).with("com.example.app").and_return(found_bundle_id)

      result = Produce::Service.new.bundle_id

      expect(result).to eq(found_bundle_id)
    end

    it "falls back to session-based login when no API key is configured" do
      config_with
      expect(Spaceship).to receive(:login).with("person@example.com", nil)
      expect(Spaceship).to receive(:select_team)
      found_bundle_id = double("bundle_id")
      allow(Spaceship::ConnectAPI::BundleId).to receive(:find).with("com.example.app").and_return(found_bundle_id)

      result = Produce::Service.new.bundle_id

      expect(result).to eq(found_bundle_id)
    end

    it "memoizes the bundle_id across calls instead of re-authenticating" do
      config_with(api_key: api_key)
      allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(fake_token)
      allow(Spaceship::ConnectAPI).to receive(:client=)
      found_bundle_id = double("bundle_id")
      expect(Spaceship::ConnectAPI::BundleId).to receive(:find).once.and_return(found_bundle_id)

      instance = Produce::Service.new
      instance.bundle_id
      result = instance.bundle_id

      expect(result).to eq(found_bundle_id)
    end
  end
end
