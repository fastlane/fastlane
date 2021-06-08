describe Produce do
  describe "Manager" do
    it "should auto convert string hash keys to symbol keys" do
      Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, {
          username: "helmut@januschka.com",
          enable_services: { "data_protection" => "complete" },
          skip_itc: true
      })

      instance = Produce::DeveloperCenter.new
      features = instance.enable_services

      expect(features["DATA_PROTECTION"].value).to eq(true)
      expect(features["DATA_PROTECTION"].capability_settings_value).to eq("COMPLETE_PROTECTION")
      expect(features["DATA_PROTECTION"].capability_settings[0][:options][0][:key]).to eq("COMPLETE_PROTECTION")
    end

    it "accepts symbol'd hash" do
      Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, {
        username: "helmut@januschka.com",
        enable_services: { data_protection: "complete" },
        skip_itc: true
      })

      instance = Produce::DeveloperCenter.new
      features = instance.enable_services

      expect(features["DATA_PROTECTION"].value).to eq(true)
      expect(features["DATA_PROTECTION"].capability_settings_value).to eq("COMPLETE_PROTECTION")
      expect(features["DATA_PROTECTION"].capability_settings[0][:options][0][:key]).to eq("COMPLETE_PROTECTION")
    end
  end
end
