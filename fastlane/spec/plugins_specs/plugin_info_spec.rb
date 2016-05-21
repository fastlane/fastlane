describe Fastlane::PluginInfo do
  describe '#gem_name' do
    it "is equal to the plugin name prepended with ''" do
      expect(Fastlane::PluginInfo.new('name', 'Me').gem_name).to eq("#{Fastlane::PluginManager::FASTLANE_PLUGIN_PREFIX}name")
    end
  end

  describe '#require_path' do
    it "is equal to the gem name with dashes becoming slashes" do
      expect(Fastlane::PluginInfo.new('name', 'Me').require_path).to eq("fastlane/plugin/name")
    end
  end
end
