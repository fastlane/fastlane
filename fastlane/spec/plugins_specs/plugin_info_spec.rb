describe Fastlane::PluginInfo do
<<<<<<< HEAD
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
=======
  describe '#gem_name' do
    it "is equal to the plugin name prepended with ''" do
      expect(Fastlane::PluginInfo.new('name', 'Me').gem_name).to eq("#{Fastlane::PluginManager::FASTLANE_PLUGIN_PREFIX}name")
>>>>>>> 532a9a6fe97ec3038deacb16b2160abcf5ca27d0
    end
  end

  describe '#require_path' do
    it "is equal to the gem name with dashes becoming slashes" do
<<<<<<< HEAD
      expect(Fastlane::PluginInfo.new('name', 'Me', 'me@you.com', 'summary', 'description').require_path).to eq("fastlane/plugin/name")
=======
      expect(Fastlane::PluginInfo.new('name', 'Me').require_path).to eq("fastlane/plugin/name")
>>>>>>> 532a9a6fe97ec3038deacb16b2160abcf5ca27d0
    end
  end
end
