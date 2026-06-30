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
      expect(features["dataProtection"].value).to eq("complete")
    end

    it "accepts symbol'd hash" do
      Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, {
        username: "helmut@januschka.com",
        enable_services: { data_protection: "complete" },
        skip_itc: true
      })

      instance = Produce::DeveloperCenter.new
      features = instance.enable_services
      expect(features["dataProtection"].value).to eq("complete")
    end

    it "skips Connect API-only services in legacy Portal enable_services" do
      Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, {
        username: "helmut@januschka.com",
        enable_services: {
          push_notification: "on",
          extended_virtual_address_space: "on",
          increased_memory_limit: "on",
        },
        skip_itc: true
      })

      instance = Produce::DeveloperCenter.new
      features = instance.enable_services

      expect(features.keys).to eq(["push"])
      expect(features.keys).not_to include("extendedVirtualAddressSpace", "increasedMemoryLimit")
    end

    it "builds Connect API service options for Produce::Service" do
      require_relative "../lib/produce/service"

      instance = Produce::DeveloperCenter.new
      options = instance.build_connect_api_service_options({
        extended_virtual_address_space: "on",
        increased_memory_limit: "on",
      })

      service = Produce::Service.new
      valid = service.send(:valid_services_for, options)

      expect(valid.keys).to contain_exactly(:extended_virtual_address_space, :increased_memory_limit)
      expect(options.extended_virtual_address_space).to eq("on")
      expect(options.increased_memory_limit).to eq("on")
    end
  end
end
