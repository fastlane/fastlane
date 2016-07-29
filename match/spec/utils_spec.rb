describe Match do
  describe Match::Utils do
    describe 'import' do
      it 'finds a normal keychain name relative to ~/Library/Keychains' do
        expected_command = "security import item.path -k #{Dir.home}/Library/Keychains/login.keychain -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"
        expect(Match::Utils.import('item.path', 'login.keychain')).to eq(expected_command)
      end

      it 'treats a keychain name it cannot find in ~/Library/Keychains as the full keychain path' do
        expected_command = "security import item.path -k /my/special.keychain -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"
        expect(Match::Utils.import('item.path', '/my/special.keychain')).to eq(expected_command)
      end
    end

    describe "fill_environment" do
      it "pre-fills the environment" do
        uuid = "my_uuid #{Time.now.to_i}"
        values = {
          app_identifier: "tools.fastlane.app",
          type: "appstore"
        }
        result = Match::Utils.fill_environment(values, uuid)
        expect(result).to eq(uuid)

        item = ENV.find { |k, v| v == uuid }
        expect(item[0]).to eq("sigh_tools.fastlane.app_appstore")
        expect(item[1]).to eq(uuid)
      end
    end
  end
end
