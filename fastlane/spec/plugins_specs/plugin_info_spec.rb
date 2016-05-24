describe Fastlane::PluginInfo do
  describe 'object equality' do
    it "detects equal PluginInfo objects" do
      object_a = Fastlane::PluginInfo.new('name', 'Me', 'me@you.com', 'summary', 'description')
      object_b = Fastlane::PluginInfo.new('name', 'Me', 'me@you.com', 'summary', 'description')
      expect(object_a).to eq(object_b)
    end

    it "detects differing PluginInfo objects" do
      object_a = Fastlane::PluginInfo.new('name', 'Me', 'me@you.com', 'summary', 'description')
      object_b = Fastlane::PluginInfo.new('name2', 'Me2', 'me2@you.com', 'summary2', 'description2')
      expect(object_a).not_to eq(object_b)
    end
  end

  describe '#gem_name' do
    it "is equal to the plugin name prepended with ''" do
      expect(Fastlane::PluginInfo.new('name', 'Me', 'me@you.com', 'summary', 'description').gem_name).to eq("#{Fastlane::PluginManager::FASTLANE_PLUGIN_PREFIX}name")
    end
  end

  describe '#require_path' do
    it "is equal to the gem name with dashes becoming slashes" do
      expect(Fastlane::PluginInfo.new('name', 'Me', 'me@you.com', 'summary', 'description').require_path).to eq("fastlane/plugin/name")
    end
  end
end
