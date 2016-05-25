require 'rubygems'

initialized = false
test_ui = nil
generator = nil
tmp_dir = nil
oldwd = nil

describe Fastlane::PluginGenerator do
  describe '#generate' do
    let(:plugin_info) { Fastlane::PluginInfo.new('tester', 'Fabricio Devtoolio', 'fabric.devtools@gmail.com', 'summary', 'description') }
    let(:plugin_name) { plugin_info.plugin_name }
    let(:gem_name) { plugin_info.gem_name }
    let(:require_path) { plugin_info.require_path }
    let(:author) { plugin_info.author }
    let(:email) { plugin_info.email }
    let(:summary) { plugin_info.summary }
    let(:description) { plugin_info.description }

    before(:each) do
      unless initialized
        test_ui = Fastlane::PluginGeneratorUI.new
        allow(test_ui).to receive(:message)
        allow(test_ui).to receive(:input).and_raise(":input call was not mocked!")
        allow(test_ui).to receive(:confirm).and_raise(":confirm call was not mocked!")

        generator = Fastlane::PluginGenerator.new(test_ui)

        tmp_dir = Dir.mktmpdir
        oldwd = Dir.pwd
        Dir.chdir(tmp_dir)

        expect(test_ui).to receive(:input).and_return(plugin_name)
        expect(test_ui).to receive(:input).and_return(author)
        expect(test_ui).to receive(:input).and_return(email)
        expect(test_ui).to receive(:input).and_return(summary)
        expect(test_ui).to receive(:input).and_return(description)

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
      readme_file = File.join(tmp_dir, gem_name, 'README.md')
      expect(File.exist?(readme_file)).to be(true)

      readme_contents = File.read(readme_file)

      expect(readme_contents).to include(gem_name)
      expect(readme_contents.length).to be > 100
    end

    it "creates a module for the VERSION" do
      # We'll be asserting that this file is valid Ruby when we check
      # the value of the version as evaluated by the gemspec!
      expect(File.exist?(File.join(tmp_dir, gem_name, 'lib', require_path, 'version.rb'))).to be(true)
    end

    it "creates a LICENSE" do
      readme_file = File.join(tmp_dir, gem_name, 'LICENSE')
      expect(File.exist?(readme_file)).to be(true)

      readme_contents = File.read(readme_file)

      expect(readme_contents).to include(author)
      expect(readme_contents).to include(email)
      expect(readme_contents.length).to be > 100
    end

    it "creates a Action class" do
      action_file = File.join(tmp_dir, gem_name, 'lib', plugin_info.actions_path, "#{plugin_info.plugin_name}_action.rb")
      expect(File.exist?(action_file)).to be(true)

      action_contents = File.read(action_file)

      # rubocop:disable Lint/Eval
      eval(action_contents)
      # rubocop:enable Lint/Eval

      # If we evaluate the contents of the generated action file,
      # we'll get the Action class defined. This ensures that the
      # syntax is valid, and lets us interrogate the class for its
      # behavior!
      action_class = Object.const_get("Fastlane::Actions::#{plugin_name.capitalize}Action")

      # Check that the default `run` method behavior calls UI.message
      expect(UI).to receive(:message).with(/#{plugin_name}/)
      action_class.run(nil)

      # Check the default behavior of the rest of the methods
      expect(action_class.description).to eq(description)
      expect(action_class.authors).to eq([author])
      expect(action_class.available_options).to eq([])
      expect(action_class.is_supported?(:ios)).to be(true)
    end

    it "creates a complete, valid gemspec" do
      gemspec_file = File.join(tmp_dir, gem_name, "#{gem_name}.gemspec")
      expect(File.exist?(gemspec_file)).to be(true)

      # Because the gemspec expects to be evaluated from the same directory
      # it lives in, we need to jump in there while we examine it.
      Dir.chdir(gem_name) do
        # If we evaluate the contents of the generated gemspec file,
        # we'll get the Gem Specification object back out, which
        # ensures that the syntax is valid, and lets us interrogate
        # the values!
        #
        # rubocop:disable Lint/Eval
        gemspec = eval(File.read(gemspec_file))
        # rubocop:enable Lint/Eval

        expect(gemspec.name).to eq(gem_name)
        expect(gemspec.author).to eq(author)
        expect(gemspec.version).to eq(Gem::Version.new('0.1.0'))
        expect(gemspec.email).to eq(email)
        expect(gemspec.summary).to eq(summary)
        expect(gemspec.description).to eq(description)
        expect(gemspec.dependencies[0].name).to eq('fastlane')
        expect(gemspec.dependencies[0].requirement.to_s).to eq(">= #{Fastlane::VERSION}")
      end
    end
  end
end
