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
        FastlaneCore::ConfigItem.new(key: :a_sensitive,
                                     description: "Metadata: A sensitive option",
                                     optional: true,
                                     sensitive: true,
                                     is_string: true,
                                     default_value: "Some secret"),
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

      value = FastlaneCore::PrintTable.print_values(config: @config, title: title, hide_keys: [:a_sensitive])
      expect(value[:title]).to eq(title.green)
      expect(value[:rows]).to eq([["cert_name", "asdf"], :separator, ["output", ".."], :separator, ["a_bool", "true"]])
    end
    it "automatically masks sensitive options" do
      value = FastlaneCore::PrintTable.print_values(config: @config)
      expect(value[:rows]).to eq([["cert_name", "asdf"], :separator, ["output", ".."], :separator, ["a_bool", "true"], :separator, ["a_sensitive", "********"]])
    end
    it "supports mask_keys property with symbols and strings" do
      value = FastlaneCore::PrintTable.print_values(config: @config, mask_keys: [:cert_name, 'a_bool'])
      expect(value[:rows]).to eq([["cert_name", "********"], :separator, ["output", ".."], :separator, ["a_bool", "********"], :separator, ["a_sensitive", "********"]])
    end

    it "supports hide_keys property with symbols and strings" do
      value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:cert_name, "a_bool", :a_sensitive])
      expect(value[:rows]).to eq([['output', '..']])
    end

    it "recurses over hashes" do
      @config[:a_hash][:foo] = 'bar'
      @config[:a_hash][:bar] = { foo: 'bar' }
      value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:cert_name, :a_bool])
      expect(value[:rows]).to eq([["output", ".."], :separator, ["a_hash.foo", "bar"], :separator, ["a_hash.bar.foo", "bar"], :separator, ["a_sensitive", "********"]])
    end

    it "supports hide_keys property in hashes" do
      @config[:a_hash][:foo] = 'bar'
      @config[:a_hash][:bar] = { foo: 'bar' }
      value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:cert_name, :a_bool, 'a_hash.foo', 'a_hash.bar.foo'])
      expect(value[:rows]).to eq([["output", ".."], :separator, ["a_sensitive", "********"]])
    end

    it "supports printing default values and ignores missing unset ones " do
      @config[:cert_name] = nil # compulsory without default
      @config[:output] = nil    # compulsory with default
      value = FastlaneCore::PrintTable.print_values(config: @config)
      expect(value[:rows]).to eq([["output", "."], :separator, ["a_bool", "true"], :separator, ["a_sensitive", "********"]])
    end
    describe "Breaks down lines" do
      let(:long_breakable_text) { 'bar ' * 4000 }
      before do
        @config[:cert_name] = long_breakable_text
      end
      it "middle truncate" do
        value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:output, :a_bool, :a_sensitive], transform: :truncate_middle)
        expect(value[:rows].count).to eq(1)
        expect(value[:rows][0][1]).to include "..."
        expect(value[:rows][0][1].length).to be < long_breakable_text.length
      end

      it "newline" do
        value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:output, :a_bool, :a_sensitive], transform: :newline)
        expect(value[:rows].count).to eq(1)
        expect(value[:rows][0][1]).to include "\n"
        expect(value[:rows][0][1].length).to be > long_breakable_text.length
      end

      it "no change" do
        value = FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [:output, :a_bool, :a_sensitive], transform: :none)
        expect(value[:rows].count).to eq(1)
        expect(value[:rows][0][1].length).to eq(long_breakable_text.length)
      end
    end

    it "supports non-Configuration prints" do
      value = FastlaneCore::PrintTable.print_values(config: { key: "value" }, title: "title")
      expect(value[:rows]).to eq([["key", "value"]])
    end
  end
end
