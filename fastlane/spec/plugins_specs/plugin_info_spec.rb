describe Fastlane::PluginInfo do
  describe '#gem_name' do
    it "is equal to the plugin name prepended with 'fastlane_'" do
      expect(Fastlane::PluginInfo.new('plugin_name', 'Me').gem_name).to eq('fastlane_plugin_name')
    end
  end
end
