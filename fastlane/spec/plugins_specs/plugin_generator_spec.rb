describe Fastlane::PluginGenerator do
  describe '#generate' do
    let(:test_ui) do
      ui = Fastlane::PluginGeneratorUI.new
      allow(ui).to receive(:message)
      allow(ui).to receive(:input)
      allow(ui).to receive(:confirm)
      ui
    end
    let(:generator) { Fastlane::PluginGenerator.new(test_ui) }
    let(:plugin_name) { "plugin" }
    let(:gem_name) { "fastlane_#{plugin_name}" }
    let(:author) { "Fabricio Devtoolio" }

    before(:each) do
      @tmp_dir = Dir.mktmpdir
      @oldwd = Dir.pwd
      Dir.chdir(@tmp_dir)

      expect(test_ui).to receive(:input).and_return(plugin_name)
      expect(test_ui).to receive(:input).and_return(author)

      generator.generate
    end

    after(:each) do
      Dir.chdir(@oldwd) if @oldwd
      FileUtils.remove_entry(@tmp_dir) if @tmp_dir
    end

    it "creates gem root directory" do
      expect(File.directory?(File.join(@tmp_dir, gem_name))).to be(true)
    end

    it "creates a README" do
      expect(File.exists?(File.join(@tmp_dir, 'README.md'))).to be(true)
    end

    it "README contains gem name" do
      expect(File.read(File.join(@tmp_dir, 'README.md')).include?(gem_name))
    end

    it "creates a LICENSE" do
      expect(File.exists?(File.join(@tmp_dir, 'LICENSE'))).to be(true)
    end

    it "creates a gemspec" do

    end

    it "creates a lib directory" do

    end


  end
end
