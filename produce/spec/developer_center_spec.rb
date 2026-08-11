require "produce/developer_center"

describe Produce::DeveloperCenter do
  let(:fake_token) { double("connect_api_token", in_house: false) }
  let(:api_key) { { key_id: "abc", issuer_id: "def", key: "fake" } }

  def config_with(overrides = {})
    Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, {
      app_identifier: "com.example.app",
      app_name: "Example App",
      username: "person@example.com",
      team_id: "TEAMID1234",
      team_name: "Example Team",
      skip_itc: true
    }.merge(overrides))
  end

  describe "#using_connect_api?" do
    it "is true when :api_key is set" do
      config_with(api_key: api_key)
      allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(fake_token)

      expect(Produce::DeveloperCenter.new.send(:using_connect_api?)).to eq(true)
    end

    it "is false when neither :api_key nor :api_key_path is set" do
      config_with

      expect(Produce::DeveloperCenter.new.send(:using_connect_api?)).to eq(false)
    end
  end

  describe "#create_new_app (App Store Connect API key path)" do
    before do
      config_with(api_key: api_key)
      allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(fake_token)
      allow(Spaceship::ConnectAPI).to receive(:client=)
    end

    it "does nothing but log when the app already exists" do
      existing_app = double("existing_bundle_id")
      allow(Spaceship::ConnectAPI::BundleId).to receive(:find).with("com.example.app").and_return(existing_app)
      expect(Spaceship::ConnectAPI::BundleId).not_to receive(:create)

      instance = Produce::DeveloperCenter.new
      instance.send(:login)
      result = instance.create_new_app

      expect(result).to eq(true)
    end

    it "creates the app via the App Store Connect API when it doesn't exist yet" do
      allow(Spaceship::ConnectAPI::BundleId).to receive(:find).with("com.example.app").and_return(nil)
      created_app = double("created_bundle_id", id: "ABC123")
      expect(Spaceship::ConnectAPI::BundleId).to receive(:create).with(
        name: "Example App",
        platform: "IOS",
        identifier: "com.example.app"
      ).and_return(created_app)

      instance = Produce::DeveloperCenter.new
      instance.send(:login)
      result = instance.create_new_app

      expect(result).to eq(true)
    end

    it "raises a clear error instead of silently ignoring inline capability flags" do
      config_with(api_key: api_key, enable_services: { push_notification: "on" })
      allow(Spaceship::ConnectAPI::BundleId).to receive(:find).and_return(nil)

      instance = Produce::DeveloperCenter.new
      instance.send(:login)

      expect { instance.create_new_app }.to raise_error(FastlaneCore::Interface::FastlaneError)
    end
  end

  describe "#login" do
    it "authenticates with the App Store Connect API key when configured" do
      config_with(api_key: api_key)
      allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(fake_token)
      expect(Spaceship::ConnectAPI).to receive(:client=)
      expect(Spaceship).not_to receive(:login)

      Produce::DeveloperCenter.new.send(:login)
    end

    it "falls back to session-based login when no API key is configured" do
      config_with
      expect(Spaceship).to receive(:login).with("person@example.com", nil)
      expect(Spaceship).to receive(:select_team)

      Produce::DeveloperCenter.new.send(:login)
    end
  end
end
