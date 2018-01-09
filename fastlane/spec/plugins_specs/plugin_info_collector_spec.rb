describe Fastlane::PluginInfoCollector do
  let(:test_ui) do
    ui = Fastlane::PluginGeneratorUI.new
    allow(ui).to receive(:message)
    allow(ui).to receive(:input).and_raise(":input call was not mocked!")
    allow(ui).to receive(:confirm).and_raise(":confirm call was not mocked!")
    ui
  end

  before do
    ["my plugin", "test_name", "my_", "fastlane-whatever", "whatever"].each do |current|
      stub_plugin_exists_on_rubygems(current, false)
    end
  end

  let(:collector) { Fastlane::PluginInfoCollector.new(test_ui) }

  describe "#collect_plugin_name" do
    describe "with no initial input" do
      it "accepts a valid plugin name" do
        expect(test_ui).to receive(:input).and_return('test_name')

        expect(collector.collect_plugin_name).to eq('test_name')
      end

      it "offers a correction" do
        expect(test_ui).to receive(:input).and_return('TEST_NAME')
        expect(test_ui).to receive(:confirm).and_return(true)

        expect(collector.collect_plugin_name).to eq('test_name')
      end

      it "offers and prompts again if declined" do
        expect(test_ui).to receive(:input).and_return('TEST NAME')
        expect(test_ui).to receive(:confirm).and_return(false)
        expect(test_ui).to receive(:message).with(/can only contain/)
        expect(test_ui).to receive(:input).and_return('test_name')

        expect(collector.collect_plugin_name).to eq('test_name')
      end
    end

    describe "with invalid initial input" do
      it "offers a correction and uses it if accepted" do
        expect(test_ui).to receive(:confirm).and_return(true)

        expect(collector.collect_plugin_name('fastlane-whatever')).to eq('whatever')
      end

      it "offers and prompts again if declined" do
        expect(test_ui).to receive(:confirm).and_return(false)
        expect(test_ui).to receive(:message).with(/can only contain/)
        expect(test_ui).to receive(:input).and_return('test_name')

        expect(collector.collect_plugin_name('my plugin')).to eq('test_name')
      end
    end

    describe "with valid initial input" do
      it "accepts a valid plugin name" do
        expect(test_ui).not_to(receive(:input))

        expect(collector.collect_plugin_name('test_name')).to eq('test_name')
      end
    end
  end

  describe '#plugin_name_valid?' do
    it "handles valid plugin name" do
      expect(collector.plugin_name_valid?('test_name')).to be_truthy
    end

    it "handles plugin name with all caps" do
      expect(collector.plugin_name_valid?('TEST_NAME')).to be_falsey
    end

    it "handles plugin name with spaces" do
      expect(collector.plugin_name_valid?('test name')).to be_falsey
    end

    it "handles plugin name with dashes" do
      expect(collector.plugin_name_valid?('test-name')).to be_falsey
    end

    it "handles plugin name containing 'fastlane'" do
      expect(collector.plugin_name_valid?('test_fastlane_name')).to be_falsey
    end

    it "handles plugin name containing 'plugin'" do
      expect(collector.plugin_name_valid?('test_plugin_name')).to be_falsey
    end

    it "handles plugin name starting with 'Fastlane '" do
      expect(collector.plugin_name_valid?('Fastlane test_name')).to be_falsey
    end

    it "handles plugin name starting with '#{Fastlane::PluginManager::FASTLANE_PLUGIN_PREFIX}'" do
      expect(collector.plugin_name_valid?("#{Fastlane::PluginManager::FASTLANE_PLUGIN_PREFIX}test_name")).to be_falsey
    end

    it "handles plugin name with characters we don't want" do
      expect(collector.plugin_name_valid?('T!EST-na$me ple&ase')).to be_falsey
    end

    it "detects if the plugin is already taken on RubyGems.org" do
      stub_plugin_exists_on_rubygems('already_taken', true)

      expect(collector.plugin_name_valid?('already_taken')).to be_falsey
    end
  end

  describe '#fix_plugin_name' do
    it "handles valid plugin name" do
      expect(collector.fix_plugin_name('test_name')).to eq('test_name')
    end

    it "handles plugin name with all caps" do
      expect(collector.fix_plugin_name('TEST_NAME')).to eq('test_name')
    end

    it "handles plugin name with spaces" do
      expect(collector.fix_plugin_name('test name')).to eq('test_name')
    end

    it "handles plugin name with dashes" do
      expect(collector.fix_plugin_name('test-name')).to eq('test_name')
    end

    it "handles plugin name containing 'fastlane'" do
      expect(collector.fix_plugin_name('test_fastlane_name')).to eq('test_name')
    end

    it "handles plugin name containing 'plugin'" do
      expect(collector.fix_plugin_name('test_plugin_name')).to eq('test_name')
    end

    it "handles plugin name starting with 'Fastlane '" do
      expect(collector.fix_plugin_name('Fastlane test_name')).to eq('test_name')
    end

    it "handles plugin name starting with '#{Fastlane::PluginManager::FASTLANE_PLUGIN_PREFIX}'" do
      expect(collector.fix_plugin_name("#{Fastlane::PluginManager::FASTLANE_PLUGIN_PREFIX}test_name")).to eq('test_name')
    end

    it "handles plugin name with characters we don't want" do
      expect(collector.fix_plugin_name('T!EST-na$me ple&ase')).to eq('test_name_please')
    end
  end

  describe "author collection" do
    it "accepts a valid author name" do
      expect(test_ui).to receive(:input).and_return('Fabricio Devtoolio')

      expect(collector.collect_author).to eq('Fabricio Devtoolio')
    end

    it "accepts a valid author name after rejecting an invalid author name" do
      expect(test_ui).to receive(:input).and_return('')
      expect(test_ui).to receive(:input).and_return('Fabricio Devtoolio')

      expect(collector.collect_author).to eq('Fabricio Devtoolio')
    end

    it "has an author name from git config" do
      expect(test_ui).not_to(receive(:input))
      expect(collector.collect_author('Fabricio Devtoolio')).to eq('Fabricio Devtoolio')
    end
  end

  describe "author detection" do
    it "has an email from git config" do
      expect(FastlaneCore::Helper).to receive(:backticks).with('git config --get user.name', print: FastlaneCore::Globals.verbose?).and_return('Fabricio Devtoolio')
      expect(collector.detect_author).to eq('Fabricio Devtoolio')
    end

    it "does not have an email from git config" do
      expect(FastlaneCore::Helper).to receive(:backticks).with('git config --get user.name', print: FastlaneCore::Globals.verbose?).and_return('')
      expect(collector.detect_author).to be(nil)
    end
  end

  describe '#author_valid?' do
    it "handles valid author" do
      expect(collector.author_valid?('Fabricio Devtoolio')).to be_truthy
    end

    it "handles empty author" do
      expect(collector.author_valid?('')).to be_falsey
    end

    it "handles all-spaces author" do
      expect(collector.author_valid?('    ')).to be_falsey
    end
  end

  describe "email collection" do
    it "accepts a provided email" do
      expect(test_ui).to receive(:input).and_return('fabric.devtools@gmail.com')

      expect(collector.collect_email).to eq('fabric.devtools@gmail.com')
    end

    it "accepts a blank email" do
      expect(test_ui).to receive(:input).and_return('')

      expect(collector.collect_email).to eq('')
    end

    it "has an email from git config" do
      expect(test_ui).not_to(receive(:input))
      expect(collector.collect_email('fabric.devtools@gmail.com')).to eq('fabric.devtools@gmail.com')
    end
  end

  describe "email detection" do
    it "has an email from git config" do
      expect(FastlaneCore::Helper).to receive(:backticks).with('git config --get user.email', print: FastlaneCore::Globals.verbose?).and_return('fabric.devtools@gmail.com')
      expect(collector.detect_email).to eq('fabric.devtools@gmail.com')
    end

    it "does not have email in git config" do
      expect(FastlaneCore::Helper).to receive(:backticks).with('git config --get user.email', print: FastlaneCore::Globals.verbose?).and_return('')
      expect(collector.detect_email).to be(nil)
    end
  end

  describe "summary collection" do
    it "accepts a valid summary" do
      expect(test_ui).to receive(:input).and_return('summary')

      expect(collector.collect_summary).to eq('summary')
    end

    it "accepts a valid summary after rejecting an invalid summary" do
      expect(test_ui).to receive(:input).and_return('')
      expect(test_ui).to receive(:input).and_return('summary')

      expect(collector.collect_summary).to eq('summary')
    end
  end

  describe "#summary_valid?" do
    it "handles valid summary" do
      expect(collector.summary_valid?('summary')).to be_truthy
    end

    it "handles an empty summary" do
      expect(collector.summary_valid?('')).to be_falsey
    end

    it "handles all-spaces summary" do
      expect(collector.summary_valid?('    ')).to be_falsey
    end
  end

  describe "details collection" do
    it "accepts a valid details" do
      expect(test_ui).to receive(:input).and_return('details')

      expect(collector.collect_details).to eq('details')
    end
  end

  describe '#collect_info' do
    it "returns a PluginInfo summarizing the user input" do
      expect(test_ui).to receive(:input).and_return('test_name')
      expect(test_ui).to receive(:input).and_return('Fabricio Devtoolio')
      expect(test_ui).to receive(:input).and_return('fabric.devtools@gmail.com')
      expect(test_ui).to receive(:input).and_return('summary')
      expect(test_ui).to receive(:input).and_return('details')
      expect(FastlaneCore::Helper).to receive(:backticks).with('git config --get user.email', print: FastlaneCore::Globals.verbose?).and_return('')
      expect(FastlaneCore::Helper).to receive(:backticks).with('git config --get user.name', print: FastlaneCore::Globals.verbose?).and_return('')

      info = Fastlane::PluginInfo.new('test_name', 'Fabricio Devtoolio', 'fabric.devtools@gmail.com', 'summary', 'details')
      expect(collector.collect_info).to eq(info)
    end
  end
end
