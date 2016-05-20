describe Fastlane::PluginInfoCollector do
  let(:test_ui) do
    ui = Fastlane::PluginGeneratorUI.new
    allow(ui).to receive(:message)
    allow(ui).to receive(:input)
    allow(ui).to receive(:confirm)
    ui
  end

  let(:collector) { Fastlane::PluginInfoCollector.new(test_ui) }

  describe "plugin name collection" do
    it "accepts a valid plugin name" do
      expect(test_ui).to receive(:input).and_return('test_name')

      expect(collector.collect_plugin_name).to eq('test_name')
    end

    it "offers a corrected plugin name for caps" do
      expect(test_ui).to receive(:input).and_return('TEST_NAME')
      expect(test_ui).to receive(:confirm).and_return(true)

      expect(collector.collect_plugin_name).to eq('test_name')
    end

    it "offers a corrected plugin name for spaces" do
      expect(test_ui).to receive(:input).and_return('test name')
      expect(test_ui).to receive(:confirm).and_return(true)

      expect(collector.collect_plugin_name).to eq('test_name')
    end

    it "offers a corrected plugin name for dashes" do
      expect(test_ui).to receive(:input).and_return('test-name')
      expect(test_ui).to receive(:confirm).and_return(true)

      expect(collector.collect_plugin_name).to eq('test_name')
    end

    it "offers a corrected plugin name for starting with 'fastlane_'" do
      expect(test_ui).to receive(:input).and_return('fastlane_test_name')
      expect(test_ui).to receive(:confirm).and_return(true)

      expect(collector.collect_plugin_name).to eq('test_name')
    end

    it "offers a corrected plugin name for starting with 'Fastlane '" do
      expect(test_ui).to receive(:input).and_return('Fastlane test_name')
      expect(test_ui).to receive(:confirm).and_return(true)

      expect(collector.collect_plugin_name).to eq('test_name')
    end

    it "offers a corrected plugin name for characters we don't want" do
      expect(test_ui).to receive(:input).and_return('T!EST-na$me ple&ase')
      expect(test_ui).to receive(:confirm).and_return(true)

      expect(collector.collect_plugin_name).to eq('test_name_please')
    end

    it "offers a corrected plugin name, and prompts again if declined" do
      expect(test_ui).to receive(:input).and_return('TEST NAME')
      expect(test_ui).to receive(:confirm).and_return(false)
      expect(test_ui).to receive(:message).with(/can only contain/)
      expect(test_ui).to receive(:input).and_return('test_name')

      expect(collector.collect_plugin_name).to eq('test_name')
    end
  end

  describe 'author collection' do
    it "accepts a valid author name" do
      expect(test_ui).to receive(:input).and_return('Fabricio Devtoolio')

      expect(collector.collect_author).to eq('Fabricio Devtoolio')
    end

    it "does not accept empty author name" do
      expect(test_ui).to receive(:input).and_return('')
      expect(test_ui).to receive(:input).and_return('Fabricio Devtoolio')

      expect(collector.collect_author).to eq('Fabricio Devtoolio')
    end

    it "does not accept whitespace-only author name" do
      expect(test_ui).to receive(:input).and_return('     ')
      expect(test_ui).to receive(:input).and_return('Fabricio Devtoolio')

      expect(collector.collect_author).to eq('Fabricio Devtoolio')
    end
  end

  describe '#collect_info' do
    it "returns a PluginInfo summarizing the user input" do
      expect(test_ui).to receive(:input).and_return('plugin_name')
      expect(test_ui).to receive(:input).and_return('Fabricio Devtoolio')

      info = Fastlane::PluginInfo.new('plugin_name', 'Fabricio Devtoolio')

      expect(collector.collect_info).to eq(info)
    end
  end
end
