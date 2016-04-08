describe FastlaneCore do
  describe FastlaneCore::PrintTable do
    before do
      @options = [
        FastlaneCore::ConfigItem.new(key: :cert_name,
                                env_name: "SIGH_PROVISIONING_PROFILE_NAME",
                             description: "Set the profile name",
                            verify_block: nil),
        FastlaneCore::ConfigItem.new(key: :output,
                                env_name: "SIGH_OUTPUT_PATH",
                             description: "Directory in which the profile should be stored",
                           default_value: ".",
                            verify_block: proc do |value|
                              UI.user_error!("Could not find output directory '#{value}'") unless File.exist?(value)
                            end),
        FastlaneCore::ConfigItem.new(key: :a_bool,
                                     description: "Metadata: A bool",
                                     optional: true,
                                     is_string: false,
                                     default_value: true),
        FastlaneCore::ConfigItem.new(key: :a_hash,
                                     description: "Metadata: A hash",
                                     optional: true,
                                     is_string: false)
      ]
      @values = {
        cert_name: "asdf",
        output: "..",
        a_bool: true,
        a_hash: {}
      }
      @config = FastlaneCore::Configuration.create(@options, @values)
    end

    it "supports nil config" do
      value = FastlaneCore::PrintTable.print_values
      expect(value).to eq({ rows: [] })
    end

    it "prints out all the information in a nice table" do
      title = "Custom Title"

      value = FastlaneCore::PrintTable.print_values(config: @config, title: title)
      expect(value[:title]).to eq(title.green)
      expect(value[:rows]).to eq([['cert_name', "asdf"], ['output', '..'], ["a_bool", true]])
    end

    it "supports mask_keys property with symbols and strings" do
      value = FastlaneCore::PrintTable.print_values(config: @config, mask_keys: [:cert_name, 'a_bool'])
      expect(value[:rows]).to eq([["cert_name", "********"], ['output', '..'], ["a_bool", "********"]])
    end

    it "supports hide_keys property with symbols and strings" do
      value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:cert_name, "a_bool"])
      expect(value[:rows]).to eq([['output', '..']])
    end

    it "recurses over hashes" do
      @config[:a_hash][:foo] = 'bar'
      @config[:a_hash][:bar] = { foo: 'bar' }
      value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:cert_name, :a_bool])
      expect(value[:rows]).to eq([['output', '..'], ['a_hash.foo', 'bar'], ['a_hash.bar.foo', 'bar']])
    end

    it "supports hide_keys property in hashes" do
      @config[:a_hash][:foo] = 'bar'
      @config[:a_hash][:bar] = { foo: 'bar' }
      value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:cert_name, :a_bool, 'a_hash.foo', 'a_hash.bar.foo'])
      expect(value[:rows]).to eq([['output', '..']])
    end

    it "supports printing default values and ignores missing unset ones " do
      @config[:cert_name] = nil # compulsory without default
      @config[:output] = nil    # compulsory with default
      value = FastlaneCore::PrintTable.print_values(config: @config)
      expect(value[:rows]).to eq([['output', '.'], ['a_bool', true]])
    end

    it "breaks down long lines" do
      long_breakable_text = 'bar ' * 40
      @config[:cert_name] = long_breakable_text
      value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:output, :a_bool])
      expect(value[:rows].count).to eq(1)
      expect(value[:rows][0][1]).to end_with '...'
      expect(value[:rows][0][1].length).to be < long_breakable_text.length
    end

    it "supports non-Configuration prints" do
      value = FastlaneCore::PrintTable.print_values(config: {key: "value"}, title: "title")
      expect(value[:rows]).to eq([["key", "value"]])
    end
  end
end
