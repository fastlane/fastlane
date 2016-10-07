describe Match do
  describe Match::Utils do
    describe 'import' do
      it 'finds a normal keychain name relative to ~/Library/Keychains' do
        expected_command = "security import item.path -k #{Dir.home}/Library/Keychains/login.keychain -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"

        expect(File).to receive(:exist?).with("#{Dir.home}/Library/Keychains/login.keychain").and_return(true)
        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: $verbose)

        Match::Utils.import('item.path', 'login.keychain')
      end

      it 'treats a keychain name it cannot find in ~/Library/Keychains as the full keychain path' do
        expected_command = "security import item.path -k /my/special.keychain -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"

        expect(File).to receive(:exist?).with("#{Dir.home}/Library/Keychains/my/special.keychain").and_return(false)
        expect(File).to receive(:exist?).with("#{Dir.home}/Library/Keychains/my/special.keychain-db").and_return(false)
        expect(File).to receive(:exist?).with('/my/special.keychain').and_return(true)

        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: $verbose)

        Match::Utils.import('item.path', '/my/special.keychain')
      end

      it 'shows a user error if the keychain path cannot be resolved' do
        expect(File).to receive(:exist?).with("#{Dir.home}/Library/Keychains/my/special.keychain").and_return(false)
        expect(File).to receive(:exist?).with("#{Dir.home}/Library/Keychains/my/special.keychain-db").and_return(false)
        expect(File).to receive(:exist?).with('/my/special.keychain').and_return(false)
        expect(File).to receive(:exist?).with('/my/special.keychain-db').and_return(false)

        expect do
          Match::Utils.import('item.path', '/my/special.keychain')
        end.to raise_error(/Could not locate the provided keychain/)
      end

      it "tries to find the macOS Sierra keychain too" do
        expected_command = "security import item.path -k #{Dir.home}/Library/Keychains/login.keychain-db -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"

        expect(File).to receive(:exist?).with("#{Dir.home}/Library/Keychains/login.keychain").and_return(false)
        expect(File).to receive(:exist?).with("#{Dir.home}/Library/Keychains/login.keychain-db").and_return(true)

        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: $verbose)

        Match::Utils.import('item.path', "login.keychain")
      end
    end

    describe "fill_environment" do
      it "#environment_variable_name uses the correct env variable" do
        result = Match::Utils.environment_variable_name(app_identifier: "tools.fastlane.app", type: "appstore")
        expect(result).to eq("sigh_tools.fastlane.app_appstore")
      end

      it "#environment_variable_name_team_id uses the correct env variable" do
        result = Match::Utils.environment_variable_name_team_id(app_identifier: "tools.fastlane.app", type: "appstore")
        expect(result).to eq("sigh_tools.fastlane.app_appstore_team-id")
      end

      it "#environment_variable_name_profile_name uses the correct env variable" do
        result = Match::Utils.environment_variable_name_profile_name(app_identifier: "tools.fastlane.app", type: "appstore")
        expect(result).to eq("sigh_tools.fastlane.app_appstore_profile-name")
      end

      it "pre-fills the environment" do
        my_key = "my_test_key"
        uuid = "my_uuid"

        result = Match::Utils.fill_environment(my_key, uuid)
        expect(result).to eq(uuid)

        item = ENV.find { |k, v| v == uuid }
        expect(item[0]).to eq(my_key)
        expect(item[1]).to eq(uuid)
      end
    end
  end
end
