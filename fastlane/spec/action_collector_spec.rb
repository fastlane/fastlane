describe Fastlane::ActionCollector do
  before(:all) { ENV.delete("FASTLANE_OPT_OUT_USAGE") }

  let(:collector) { Fastlane::ActionCollector.new }

  describe "#determine_version" do
    it "accesses the version number of the other tools" do
      expect(collector.determine_version(:gym)).to eq(Fastlane::VERSION)
      expect(collector.determine_version(:sigh)).to eq(Fastlane::VERSION)
    end

    it "fetches the version of the plugin, if action is part of a plugin" do
      module Fastlane::MyPlugin
        VERSION = '1.2.3'
      end

      expect(collector.determine_version("fastlane-plugin-my_plugin/xcversion")).to eq('1.2.3')
    end

    it "returns 'undefined' if plugin version information is not available" do
      expect(collector.determine_version("fastlane-plugin-nonexistent/action_name")).to eq('undefined')
    end

    it "falls back to the fastlane version number" do
      expect(collector.determine_version(:fastlane)).to eq(Fastlane::VERSION)
      expect(collector.determine_version(:xcode_install)).to eq(Fastlane::VERSION)
    end
  end
end
