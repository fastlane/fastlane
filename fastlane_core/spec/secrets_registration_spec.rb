describe "Masking secrets in output" do
  let(:options) do
    [
      FastlaneCore::ConfigItem.new(key: :api_token, env_name: "SECRETS_SPEC_TOKEN", description: "token", sensitive: true, optional: true),
      FastlaneCore::ConfigItem.new(key: :name, description: "name", optional: true)
    ]
  end

  describe FastlaneCore::Configuration do
    it "registers a sensitive value passed as a parameter" do
      FastlaneCore::Configuration.create(options, { api_token: "param-1234" })

      expect(FastlaneCore::Secrets.mask("param-1234")).to eq("API_TOKEN_REDACTED")
    end

    it "registers a sensitive value from an environment variable when it is fetched" do
      FastlaneSpec::Env.with_env_values("SECRETS_SPEC_TOKEN" => "env-1234") do
        FastlaneCore::Configuration.create(options, {})[:api_token]
      end

      expect(FastlaneCore::Secrets.mask("env-1234")).to eq("API_TOKEN_REDACTED")
    end

    it "does not register values of other options" do
      FastlaneCore::Configuration.create(options, { name: "visible-1234" })[:name]

      expect(FastlaneCore::Secrets.mask("visible-1234")).to eq("visible-1234")
    end
  end

  describe FastlaneCore::Shell do
    it "masks secrets in every UI message" do
      FastlaneCore::Secrets.register("tok-1234")
      formatter = FastlaneCore::Shell.new.log.formatter

      expect(formatter.call("INFO", Time.now, nil, "$ API_TOKEN=tok-1234 true")).to end_with("$ API_TOKEN=******** true\n")
    end
  end

  describe FastlaneCore::PrintTable do
    it "masks cells before wrapping them, which would split the value" do
      FastlaneCore::Secrets.register("tok-PROBE-1234")
      allow(FastlaneCore::PrintTable).to receive(:should_transform?).and_return(true)
      allow(TTY::Screen).to receive(:width).and_return(90)

      rows = FastlaneCore::PrintTable.transform_output([[1, "API_TOKEN=tok-PROBE-1234 true", 0]])

      expect(rows.join).not_to include("PROBE")
      expect(rows.join).to include("********")
    end
  end
end
