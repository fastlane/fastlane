describe Fastlane do
  describe "Plugins" do
    describe "Error handling of invalid plugins" do
      it "shows an appropriate error message when an action is not available, even though a plugin was added" do
        expect do
          expect_any_instance_of(Fastlane::PluginManager).to receive(:available_plugins).and_return(["fastlane_my_custom_plugin"])
          result = Fastlane::FastFile.new.parse("lane :test do
            my_custom_plugin
          end").runner.execute(:test)
        end.to raise_exception("Plugin 'my_custom_plugin' was not properly loaded, make sure to follow the plugin docs for troubleshooting")
      end
    end
  end
end
