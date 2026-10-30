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

    it "falls back to session-based login when no API key is configured and no token exists" do
      config_with
      allow(Spaceship::ConnectAPI).to receive(:token).and_return(nil)
      expect(Spaceship).to receive(:login).with("person@example.com", nil)
      expect(Spaceship).to receive(:select_team)
      found_bundle_id = double("bundle_id")
      allow(Spaceship::ConnectAPI::BundleId).to receive(:find).with("com.example.app").and_return(found_bundle_id)

      result = Produce::Service.new.bundle_id

      expect(result).to eq(found_bundle_id)
    end

    it "reuses a token already set by another lane instead of logging in again" do
      config_with
      allow(Spaceship::ConnectAPI).to receive(:token).and_return(fake_token)
      expect(Spaceship).not_to receive(:login)
      found_bundle_id = double("bundle_id")
      allow(Spaceship::ConnectAPI::BundleId).to receive(:find).with("com.example.app").and_return(found_bundle_id)

      result = Produce::Service.new.bundle_id

      expect(result).to eq(found_bundle_id)
    end

    it "does not crash when the active config has no :api_key option at all (e.g. modify_services)" do
      # Mirrors Fastlane::Actions::ModifyServicesAction.available_options, which never declares
      # :api_key/:api_key_path - Produce.config[:api_key] would raise before reaching the
      # session-login fallback.
      narrow_options = [
        FastlaneCore::ConfigItem.new(key: :username, description: "Username"),
        FastlaneCore::ConfigItem.new(key: :app_identifier, description: "App Identifier"),
        FastlaneCore::ConfigItem.new(key: :team_id, description: "Team ID", optional: true)
      ]
      Produce.config = FastlaneCore::Configuration.create(narrow_options, {
        username: "person@example.com",
        app_identifier: "com.example.app",
        team_id: "TEAMID1234"
      })
      allow(Spaceship::ConnectAPI).to receive(:token).and_return(nil)
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
