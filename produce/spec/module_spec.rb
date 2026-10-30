require "produce/module"
require "produce/options"

describe Produce do
  describe ".config_value" do
    it "returns the value when the active config declares the key" do
      Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, {
        app_identifier: "com.example.app",
        username: "person@example.com",
        team_id: "TEAMID1234",
        team_name: "Example Team",
        skip_itc: true,
        api_key: { key_id: "abc", issuer_id: "def", key: "fake" }
      })

      expect(Produce.config_value(:api_key)).to eq(key_id: "abc", issuer_id: "def", key: "fake")
    end

    it "returns nil instead of raising when the active config does not declare the key" do
      narrow_options = [
        FastlaneCore::ConfigItem.new(key: :username, description: "Username")
      ]
      Produce.config = FastlaneCore::Configuration.create(narrow_options, { username: "person@example.com" })

      expect(Produce.config_value(:api_key)).to be_nil
    end
  end
end
