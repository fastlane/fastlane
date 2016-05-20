describe Fastlane do
  describe Fastlane::PluginManager do
    describe "#gemfile_path" do
      it "returns an absolute path if Gemfile available" do
        expect(Fastlane::PluginManager.new.gemfile_path).to eq(File.expand_path("Gemfile"))
      end

      it "returns nil if no Gemfile available" do
        expect(Bundler::SharedHelpers).to receive(:default_gemfile).and_raise(Bundler::GemfileNotFound)
        expect(Fastlane::PluginManager.new.gemfile_path).to eq(nil)
      end
    end

    describe "#plugin_prefix" do
      it "returns the correct value" do
        expect(Fastlane::PluginManager.plugin_prefix).to eq("fastlane_")
      end
    end

    describe "#available_gems" do
      it "returns [] if no Gemfile is available" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_raise(Bundler::GemfileNotFound)
        expect(Fastlane::PluginManager.new.available_gems).to eq([])
      end

      it "returns all fastlane plugins with no fastlane_core" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./spec/fixtures/plugins/Pluginfile1")
        expect(Fastlane::PluginManager.new.available_gems).to eq(["fastlane_xcversion", "fastlane_core", "hemal"])
      end
    end

    describe "#available_plugins" do
      it "returns [] if no Gemfile is available" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_raise(Bundler::GemfileNotFound)
        expect(Fastlane::PluginManager.new.available_plugins).to eq([])
      end

      it "returns all fastlane plugins with no fastlane_core" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./spec/fixtures/plugins/Pluginfile1")
        expect(Fastlane::PluginManager.new.available_plugins).to eq(["fastlane_xcversion"])
      end
    end

    describe "#plugin_is_added_as_dependency?" do
      before do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./spec/fixtures/plugins/Pluginfile1")
      end

      it "returns true if a plugin is available" do
        expect(Fastlane::PluginManager.new.plugin_is_added_as_dependency?('fastlane_xcversion')).to eq(true)
      end

      it "returns false if a plugin is available" do
        expect(Fastlane::PluginManager.new.plugin_is_added_as_dependency?('fastlane_hemal')).to eq(false)
      end

      it "raises an error if parameter doesn't start with fastlane plugin prefix" do
        expect do
          Fastlane::PluginManager.new.plugin_is_added_as_dependency?('hemal')
        end.to raise_error("fastlane plugins must start with 'fastlane_' string")
      end
    end

    describe "#install_dependencies!" do
      it "execs out the correct command" do
        pm = Fastlane::PluginManager.new
        expect(pm).to receive(:ensure_plugins_attached!)
        expect(pm).to receive(:exec).with("bundle install --quiet && echo 'Successfully installed plugins'")
        pm.install_dependencies!
      end
    end

    describe "Error handling of invalid plugins" do
      it "shows an appropriate error message when an action is not available, even though a plugin was added" do
        expect do
          expect_any_instance_of(Fastlane::PluginManager).to receive(:available_plugins).and_return(["fastlane_my_custom_plugin"])
          result = Fastlane::FastFile.new.parse("lane :test do
            my_custom_plugin
          end").runner.execute(:test)
        end.to raise_exception("Plugin 'my_custom_plugin' was not properly loaded, make sure to follow the plugin docs for troubleshooting")
      end

      it "shows an appropriate error message when an action is not available, which is not a plugin" do
        expect do
          expect_any_instance_of(Fastlane::PluginManager).to receive(:available_plugins).and_return([])
          result = Fastlane::FastFile.new.parse("lane :test do
            my_custom_plugin
          end").runner.execute(:test)
        end.to raise_exception("Could not find action or lane 'my_custom_plugin'. Check out the README for more details: https://github.com/fastlane/fastlane/tree/master/fastlane")
      end
    end
  end
end
