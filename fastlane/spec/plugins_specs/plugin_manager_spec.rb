describe Fastlane do
  describe Fastlane::PluginManager do
    let(:plugin_manager) { Fastlane::PluginManager.new }
    describe "#gemfile_path" do
      it "returns an absolute path if Gemfile available" do
        expect(plugin_manager.gemfile_path).to eq(File.expand_path("./Gemfile"))
      end

      it "returns nil if no Gemfile available" do
        expect(Bundler::SharedHelpers).to receive(:default_gemfile).and_raise(Bundler::GemfileNotFound)
        expect(plugin_manager.gemfile_path).to eq(nil)
      end
    end

    describe "#plugin_prefix" do
      it "returns the correct value" do
        expect(Fastlane::PluginManager.plugin_prefix).to eq("fastlane-plugin-")
      end
    end

    describe "#available_gems" do
      it "returns [] if no Gemfile is available" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_raise(Bundler::GemfileNotFound)
        expect(plugin_manager.available_gems).to eq([])
      end

      it "returns all fastlane plugins with no fastlane_core" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./fastlane/spec/fixtures/plugins/Pluginfile1")
        expect(plugin_manager.available_gems).to eq(["fastlane-plugin-xcversion", "fastlane_core", "hemal"])
      end
    end

    describe "#available_plugins" do
      it "returns [] if no Gemfile is available" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_raise(Bundler::GemfileNotFound)
        expect(plugin_manager.available_plugins).to eq([])
      end

      it "returns all fastlane plugins with no fastlane_core" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./fastlane/spec/fixtures/plugins/Pluginfile1")
        expect(plugin_manager.available_plugins).to eq(["fastlane-plugin-xcversion"])
      end
    end

    describe "#plugin_is_added_as_dependency?" do
      before do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./fastlane/spec/fixtures/plugins/Pluginfile1")
      end

      it "returns true if a plugin is available" do
        expect(plugin_manager.plugin_is_added_as_dependency?('fastlane-plugin-xcversion')).to eq(true)
      end

      it "returns false if a plugin is available" do
        expect(plugin_manager.plugin_is_added_as_dependency?('fastlane-plugin-hemal')).to eq(false)
      end

      it "raises an error if parameter doesn't start with fastlane plugin prefix" do
        expect do
          plugin_manager.plugin_is_added_as_dependency?('hemal')
        end.to raise_error("fastlane plugins must start with 'fastlane-plugin-' string")
      end
    end

    describe "#plugins_attached?" do
      it "returns true if plugins are attached" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./fastlane/spec/fixtures/plugins/GemfileWithAttached")
        expect(plugin_manager.plugins_attached?).to eq(true)
      end

      it "returns false if plugins are not attached" do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./fastlane/spec/fixtures/plugins/GemfileWithoutAttached")
        expect(plugin_manager.plugins_attached?).to eq(false)
      end
    end

    describe "#install_dependencies!" do
      it "execs out the correct command" do
        expect(plugin_manager).to receive(:ensure_plugins_attached!)
        expect(plugin_manager).to receive(:exec).with("bundle install --quiet && echo 'Successfully installed plugins'")
        plugin_manager.install_dependencies!
      end
    end

    describe "#update_dependencies!" do
      before do
        allow(Bundler::SharedHelpers).to receive(:default_gemfile).and_return("./fastlane/spec/fixtures/plugins/Pluginfile1")
      end

      it "execs out the correct command" do
        expect(plugin_manager).to receive(:ensure_plugins_attached!)
        expect(plugin_manager).to receive(:exec).with("bundle update fastlane-plugin-xcversion --quiet && echo 'Successfully updated plugins'")
        plugin_manager.update_dependencies!
      end
    end

    describe "#gem_dependency_suffix" do
      it "default to RubyGems if gem is available" do
        expect(Fastlane::PluginManager).to receive(:fetch_gem_info_from_rubygems).and_return({ anything: :really })
        expect(plugin_manager.gem_dependency_suffix("fastlane")).to eq("")
      end

      describe "Gem is not available on RubyGems.org" do
        before do
          expect(Fastlane::PluginManager).to receive(:fetch_gem_info_from_rubygems).and_return(nil)
        end

        it "supports specifying a custom local path" do
          expect(FastlaneCore::UI.current).to receive(:select).and_return("Local Path")
          expect(FastlaneCore::UI.current).to receive(:input).and_return("../yoo")
          expect(plugin_manager.gem_dependency_suffix("fastlane")).to eq(", path: '../yoo'")
        end

        it "supports specifying a custom git URL" do
          expect(FastlaneCore::UI.current).to receive(:select).and_return("Git URL")
          expect(FastlaneCore::UI.current).to receive(:input).and_return("https://github.com/fastlane/fastlane")
          expect(plugin_manager.gem_dependency_suffix("fastlane")).to eq(", git: 'https://github.com/fastlane/fastlane'")
        end

        it "supports falling back to RubyGems" do
          expect(FastlaneCore::UI.current).to receive(:select).and_return("RubyGems.org ('fastlane' seems to not be available there)")
          expect(plugin_manager.gem_dependency_suffix("fastlane")).to eq("")
        end
      end
    end

    describe "Previously bundled action" do
      it "#formerly_bundled_actions returns an array of string" do
        expect(Fastlane::Actions.formerly_bundled_actions).to be_kind_of(Array)

        Fastlane::Actions.formerly_bundled_actions.each do |current|
          expect(current).to be_kind_of(String)
        end
      end

      it "shows how to install a plugin if you want to use a previously bundled action" do
        deprecated_action = "deprecated"
        expect(Fastlane::Actions).to receive(:formerly_bundled_actions).and_return([deprecated_action])

        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            #{deprecated_action}
          end").runner.execute(:test)
        end.to raise_exception("The action '#{deprecated_action}' is no longer bundled with fastlane. You can install it using `fastlane add_plugin deprecated`")
      end

      it "runs the action as expected if the plugin is available" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        # We don't need to set this, since this method shouldn't even be called when the plugin is available
        # expect(Fastlane::Actions).to receive(:formerly_bundled_actions).and_return(["crashlytics"])

        Fastlane::FastFile.new.parse("lane :test do
          crashlytics({
            crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            api_token: 'wadus',
            build_secret: 'secret',
            ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
          })
        end").runner.execute(:test)
      end
    end

    describe "#add_dependency" do
      it "shows an error if a dash is used" do
        pm = Fastlane::PluginManager.new
        expect(pm).to receive(:pluginfile_path).and_return(".")
        expect do
          pm.add_dependency("ya-tu_sabes")
        end.to raise_error("Plugin name must not contain a '-', did you mean '_'?")
      end

      it "works with valid parameters" do
        pm = Fastlane::PluginManager.new
        expect(pm).to receive(:pluginfile_path).and_return(".")
        expect(pm).to receive(:plugin_is_added_as_dependency?).with("fastlane-plugin-tunes").and_return(true)
        expect(pm).to receive(:ensure_plugins_attached!)

        pm.add_dependency("tunes")
      end
    end

    describe "Overwriting plugins" do
      it "shows a warning if a plugin overwrites an existing action" do
        module Fastlane::Crashlytics
        end

        pm = Fastlane::PluginManager.new
        plugin_name = "crashlytics"
        expect(pm).to receive(:available_plugins).and_return([plugin_name])
        expect(Fastlane::FastlaneRequire).to receive(:install_gem_if_needed).with(gem_name: plugin_name, require_gem: true)
        expect(Fastlane::Crashlytics).to receive(:all_classes).and_return(["/actions/#{plugin_name}.rb"])
        expect(UI).to receive(:important).with("Plugin 'Crashlytics' overwrites already loaded action '#{plugin_name}'")
        pm.load_plugins
      end
    end

    describe "Error handling of invalid plugins" do
      it "shows an appropriate error message when an action is not available, even though a plugin was added" do
        expect do
          expect_any_instance_of(Fastlane::PluginManager).to receive(:available_plugins).and_return(["fastlane-plugin-my_custom_plugin"])
          result = Fastlane::FastFile.new.parse("lane :test do
            my_custom_plugin
          end").runner.execute(:test)
        end.to raise_exception("Plugin 'my_custom_plugin' was not properly loaded, make sure to follow the plugin docs for troubleshooting: https://docs.fastlane.tools/plugins/plugins-troubleshooting/")
      end

      it "shows an appropriate error message when an action is not available, which is not a plugin" do
        expect do
          expect_any_instance_of(Fastlane::PluginManager).to receive(:available_plugins).and_return([])
          result = Fastlane::FastFile.new.parse("lane :test do
            my_custom_plugin
          end").runner.execute(:test)
        end.to raise_exception("Could not find action, lane or variable 'my_custom_plugin'. Check out the documentation for more details: https://docs.fastlane.tools/actions")
      end

      it "shows an appropriate error message when a plugin is really broken" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        ex = ScriptError.new
        pm = Fastlane::PluginManager.new
        plugin_name = "broken"
        expect(pm).to receive(:available_plugins).and_return([plugin_name])
        expect(Fastlane::FastlaneRequire).to receive(:install_gem_if_needed).with(gem_name: plugin_name, require_gem: true).and_raise(ex)
        expect(UI).to receive(:error).with("Error loading plugin '#{plugin_name}': #{ex}")
        pm.load_plugins
        expect(pm.plugin_references[plugin_name]).not_to(be_nil)
      end
    end
  end
end
