describe Fastlane::ActionCollector do
  before(:all) { ENV.delete("FASTLANE_OPT_OUT_USAGE") }

  let(:collector) { Fastlane::ActionCollector.new }
  let(:plugin_references) do
    {
      "fastlane-plugin-my_plugin" => {
        version_number: "0.1.0",
        actions: [:xcversion, :xcyolo_something]
      }
    }
  end

  describe "#name_to_track" do
    it "returns the original name when it's a built-in action" do
      expect(collector.name_to_track(:gym)).to eq(:gym)
    end

    it "returns nil when it's an external action" do
      expect(collector).to receive(:is_official?).and_return(false)
      expect(collector.name_to_track(:fastlane)).to eq(nil)
    end

    it "returns the plugin's name if the action is part of a plugin" do
      allow(collector).to receive(:is_official?).and_return(false)
      allow(Fastlane.plugin_manager).to receive(:plugin_references).and_return(plugin_references)

      expect(collector.name_to_track(:xcyolo_something)).to eq("fastlane-plugin-my_plugin/xcyolo_something")
      expect(collector.name_to_track(:xc_not_availalbe)).to eq(nil)
    end
  end

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
      expect(collector.determine_version("fastlane-plugin-not-existent/action_name")).to eq('undefined')
    end

    it "falls back to the fastlane version number" do
      expect(collector.determine_version(:fastlane)).to eq(Fastlane::VERSION)
      expect(collector.determine_version(:xcode_install)).to eq(Fastlane::VERSION)
    end
  end
end
