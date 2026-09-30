describe Match do
  describe Match::Utils do
    before(:each) do
      allow(FastlaneCore::UI).to receive(:interactive?).and_return(false)

      allow(Security::InternetPassword).to receive(:find).and_return(nil)

      allow(Security::Keychain).to receive(:supports_key_partition_list?).and_return(true)
    end

    describe 'import' do
      it 'finds a normal keychain name relative to ~/Library/Keychains' do
        keychain_path = "#{Dir.home}/Library/Keychains/login.keychain"

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with("#{Dir.home}/Library/Keychains/login.keychain").and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with('item.path').and_return(true)

        expect(Security::Certificate).to receive(:import).with('item.path', keychain: keychain_path, password: '', format: nil).and_return(true)
        expect_any_instance_of(Security::Keychain).to receive(:set_key_partition_list) { |target, password| expect([target.filename, password]).to eq(["#{Dir.home}/Library/Keychains/login.keychain", '']) }

        Match::Utils.import('item.path', 'login.keychain', password: '')
      end

      it 'treats a keychain name it cannot find in ~/Library/Keychains as the full keychain path' do
        tmp_path = Dir.mktmpdir
        keychain = "#{tmp_path}/my/special.keychain"

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with(keychain).and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with('item.path').and_return(true)

        expect(Security::Certificate).to receive(:import).with('item.path', keychain: keychain, password: '', format: nil).and_return(true)
        expect_any_instance_of(Security::Keychain).to receive(:set_key_partition_list) { |target, password| expect([target.filename, password]).to eq([keychain, '']) }

        Match::Utils.import('item.path', keychain, password: '')
      end

      it 'shows a user error if the keychain path cannot be resolved' do
        allow(File).to receive(:exist?).and_return(false)

        expect do
          Match::Utils.import('item.path', '/my/special.keychain')
        end.to raise_error(/Could not locate the provided keychain/)
      end

      it "tries to find the macOS Sierra keychain too" do
        keychain_path = "#{Dir.home}/Library/Keychains/login.keychain-db"

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with("#{Dir.home}/Library/Keychains/login.keychain-db").and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with("item.path").and_return(true)

        expect(Security::Certificate).to receive(:import).with('item.path', keychain: keychain_path, password: '', format: nil).and_return(true)
        expect_any_instance_of(Security::Keychain).to receive(:set_key_partition_list) { |target, password| expect([target.filename, password]).to eq(["#{Dir.home}/Library/Keychains/login.keychain-db", '']) }

        Match::Utils.import('item.path', "login.keychain")
      end

      describe "keychain_password" do
        it 'prompts for keychain password when none given and not in keychain' do
          keychain_path = "#{Dir.home}/Library/Keychains/login.keychain"

          allow(Security::InternetPassword).to receive(:find).and_return(nil)
          allow(FastlaneCore::UI).to receive(:interactive?).and_return(true)

          expect(FastlaneCore::Helper).to receive(:ask_password).and_return('user_entered')
          expect(Security::InternetPassword).to receive(:add).with('fastlane_keychain_login', anything, 'user_entered')

          allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
          allow(File).to receive(:file?).and_return(false)
          expect(File).to receive(:file?).with("#{Dir.home}/Library/Keychains/login.keychain").and_return(true)
          allow(File).to receive(:exist?).and_return(false)
          expect(File).to receive(:exist?).with('item.path').and_return(true)

          expect(Security::Certificate).to receive(:import).with('item.path', keychain: keychain_path, password: '', format: nil).and_return(true)
          expect_any_instance_of(Security::Keychain).to receive(:set_key_partition_list) { |target, password| expect([target.filename, password]).to eq(["#{Dir.home}/Library/Keychains/login.keychain", 'user_entered']) }

          Match::Utils.import('item.path', 'login.keychain')
        end

        it 'find keychain password in keychain when none given' do
          keychain_path = "#{Dir.home}/Library/Keychains/login.keychain"

          item = double
          allow(item).to receive(:password).and_return('from_keychain')
          allow(Security::InternetPassword).to receive(:find).and_return(item)

          allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
          allow(File).to receive(:file?).and_return(false)
          expect(File).to receive(:file?).with("#{Dir.home}/Library/Keychains/login.keychain").and_return(true)
          allow(File).to receive(:exist?).and_return(false)
          expect(File).to receive(:exist?).with('item.path').and_return(true)

          expect(Security::Certificate).to receive(:import).with('item.path', keychain: keychain_path, password: '', format: nil).and_return(true)
          expect_any_instance_of(Security::Keychain).to receive(:set_key_partition_list) { |target, password| expect([target.filename, password]).to eq(["#{Dir.home}/Library/Keychains/login.keychain", 'from_keychain']) }

          Match::Utils.import('item.path', 'login.keychain')
        end
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

      it "#environment_variable_name_profile_path uses the correct env variable" do
        result = Match::Utils.environment_variable_name_profile_path(app_identifier: "tools.fastlane.app", type: "appstore")
        expect(result).to eq("sigh_tools.fastlane.app_appstore_profile-path")
      end

      it "#environment_variable_name_certificate_name uses the correct env variable" do
        result = Match::Utils.environment_variable_name_certificate_name(app_identifier: "tools.fastlane.app", type: "appstore")
        expect(result).to eq("sigh_tools.fastlane.app_appstore_certificate-name")
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
