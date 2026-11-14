describe Fastlane do
  describe Fastlane::FastFile do
    describe "import_from_spec" do
      it "raises an exception when no gem is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            import_from_gem
          end").runner.execute(:test)
        end.to raise_error("Please pass a gem name to the `import_from_gem` action")
      end

      it "tells the user to add the gem to the Gemfile when it is not installed" do
        allow(Bundler.rubygems).to receive(:find_name).with("not_installed_lanes").and_return([])
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            import_from_gem(gem_name: 'not_installed_lanes')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find gem 'not_installed_lanes', make sure it is in your Gemfile")
      end

      # full integration tests: a project whose Fastfile imports lanes from a gem, run out of process
      def run_fastlane_in_import_from_gem_project(arguments)
        run_in_fixture_bundle("fastlane/spec/fixtures/plugins/ImportFromGem", "fastlane #{arguments}")
      end

      it "loads all fastfile paths specified and find the lanes" do
        output = run_fastlane_in_import_from_gem_project("lanes")
        expect(output.index("----- fastlane first")).not_to eq(nil)
        expect(output.index("----- fastlane second")).not_to eq(nil)
      end

      it "runs imported actions from an imported gem" do
        output = run_fastlane_in_import_from_gem_project("first")
        expect(output.index("Step: example_action")).not_to eq(nil)
        expect(output.index("App automation done right")).not_to eq(nil)
      end

      it "loads the plugins the imported gem depends on" do
        output = run_fastlane_in_import_from_gem_project("plugin_action")
        expect(output).to include("shared_fixture loaded: true")
      end
    end
  end
end
