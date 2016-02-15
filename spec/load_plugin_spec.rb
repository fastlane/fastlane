describe Fastlane do
  describe Fastlane::FastFile do
    describe "load_plugin" do
      it "works as expected" do
        # before
        expect(Fastlane::Actions.const_defined?("RemotePluginAction")).to be(false)

        # change
        url = "https://github.com/fastlane/plugin_example"
        f = "fake"
        path = "spec/"
        expect(Fastlane::GitFetcher).to receive(:new).and_return(f)
        expect(f).to receive(:clone).with({
          url: url,
          branch: "HEAD",
          path: "fixtures/actions/remote_plugin.rb"
        }).and_return(path)

        Fastlane::FastFile.new.parse("lane :test do
          load_plugin(url: '#{url}', path: 'fixtures/actions/remote_plugin.rb')
        end").runner.execute(:test)

        # after
        expect(Fastlane::Actions.const_defined?("RemotePluginAction")).to be(true)
        expect(Fastlane::Actions::RemotePluginAction.description.length).to be > 0
      end

      it "raises an error with the .rb extension is missing" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            load_plugin(url: 'https://', path: 'remote_plugin')
          end").runner.execute(:test)
        end.to raise_error("Make sure the plugin has a `.rb` extension")
      end

      it "shows up in the action list" do
        # To be sure the mock action is there (load_plugin.rb)
        expect(Fastlane::Actions::LoadPluginAction.description.length).to be > 0
      end
    end
  end
end
