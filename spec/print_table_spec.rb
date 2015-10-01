describe FastlaneCore do
  describe FastlaneCore::PrintTable do
    before do
      @options = [
        FastlaneCore::ConfigItem.new(key: :cert_name,
                                env_name: "SIGH_PROVISIONING_PROFILE_NAME",
                             description: "Set the profile name",
                           default_value: "production_default",
                            verify_block: nil),
        FastlaneCore::ConfigItem.new(key: :output,
                                env_name: "SIGH_OUTPUT_PATH",
                             description: "Directory in which the profile should be stored",
                           default_value: ".",
                            verify_block: proc do |value|
                              raise "Could not find output directory '#{value}'".red unless File.exist?(value)
                            end)
      ]
      @values = {
        cert_name: "asdf",
        output: ".."
      }
      @config = FastlaneCore::Configuration.create(@options, @values)
    end

    it "prints out all the information in a nice table" do
      title = "Custom Title"

      value = FastlaneCore::PrintTable.print_values(config: @config, title: title)
      expect(value[:title]).to eq(title)
      expect(value[:rows]).to eq([[:cert_name, "asdf"], [:output, '..']])
    end
  end
end
