require 'rubygems'

initialized = false
test_ui = nil
generator = nil
tmp_dir = nil
oldwd = nil

describe Fastlane::PluginGenerator do
  describe '#generate' do
    let(:plugin_name) { "plugin" }
    let(:gem_name) { "fastlane_#{plugin_name}" }
    let(:author) { "Fabricio Devtoolio" }

    before(:each) do
      unless initialized
        test_ui = Fastlane::PluginGeneratorUI.new
        allow(test_ui).to receive(:message)
        allow(test_ui).to receive(:input)
        allow(test_ui).to receive(:confirm)

        generator = Fastlane::PluginGenerator.new(test_ui)

        tmp_dir = Dir.mktmpdir
        oldwd = Dir.pwd
        Dir.chdir(tmp_dir)

        expect(test_ui).to receive(:input).and_return(plugin_name)
        expect(test_ui).to receive(:input).and_return(author)

        generator.generate

        initialized = true
      end
    end

    after(:all) do
      Dir.chdir(oldwd) if oldwd
      FileUtils.remove_entry(tmp_dir) if tmp_dir

      test_ui = nil
      generator = nil
      tmp_dir = nil
      oldwd = nil
      initialized = false
    end

    it "creates gem root directory" do
      expect(File.directory?(File.join(tmp_dir, gem_name))).to be(true)
    end

    it "creates a README that contains the gem name" do
      expect(File.exist?(File.join(tmp_dir, 'README.md'))).to be(true)

      readme_contents = File.read(File.join(tmp_dir, 'README.md'))

      expect(readme_contents).to include(gem_name)
      expect(readme_contents.length).to be > 100
    end

    it "creates a module for the VERSION" do
      # We'll be asserting that this file is valid Ruby when we check
      # the value of the version as evaluated by the gemspec!
      expect(File.exist?(File.join('lib', gem_name, 'version.rb'))).to be(true)
    end

    it "creates a LICENSE" do
      expect(File.exist?(File.join(tmp_dir, 'LICENSE'))).to be(true)
    end

    it "creates a complete, valid gemspec" do
      gemspec_file = File.join(tmp_dir, "#{gem_name}.gemspec")

      expect(File.exist?(gemspec_file)).to be(true)

      # If we evaluate the contents of the generated gemspec file,
      # we'll get the Gem Specification object back out, which
      # ensures that the syntax is valid, and lets us interrogate
      # the values!
      gemspec = eval(File.read(gemspec_file))

      expect(gemspec.name).to eq(gem_name)
      expect(gemspec.author).to eq(author)
      expect(gemspec.version).to eq(Gem::Version.new('0.1.0'))
    end
  end
end
