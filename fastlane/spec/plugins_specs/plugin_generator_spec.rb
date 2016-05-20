describe Fastlane::PluginGenerator do
  describe '#generate' do
    before(:each) do
      @ui = Fastlane::PluginGeneratorUI.new
      allow(@ui).to receive(:message)
      allow(@ui).to receive(:input)
      allow(@ui).to receive(:confirm)

      @generator = Fastlane::PluginGenerator.new(@ui)

      @tmp_dir = Dir.mktmpdir
      @oldwd = Dir.pwd
      Dir.chdir(@tmp_dir)

      expect(@ui).to receive(:input).and_return('plugin')
      expect(@ui).to receive(:input).and_return('Fabricio Devtoolio')

      @generator.generate
    end

    after(:each) do
      Dir.chdir(@oldwd) if @oldwd
      FileUtils.remove_entry(@tmp_dir) if @tmp_dir
    end

    it "creates plugin root directory" do
      expect(File.directory?(File.join(@tmp_dir, 'fastlane_plugin'))).to be(true)
    end

    it "creates a README" do
      expect(File.exists?(File.join(@tmp_dir, 'README.md'))).to be(true)
    end

    it "README contains gem name" do
      expect(File.read(File.join(@tmp_dir, 'README.md')).include?('fastlane_plugin'))
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
