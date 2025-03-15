describe Match do
  describe Match::Utils do
    let(:thread) { double }

    before(:each) do
      value = double
      allow(value).to receive(:success?).and_return(true)
      allow(thread).to receive(:value).and_return(value)

      allow(FastlaneCore::UI).to receive(:interactive?).and_return(false)

      allow(Security::InternetPassword).to receive(:find).and_return(nil)

      allow(FastlaneCore::Helper).to receive(:backticks).with('security -h | grep set-key-partition-list', print: false).and_return('    set-key-partition-list               Set the partition list of a key.')
    end

    describe 'import' do
      it 'finds a normal keychain name relative to ~/Library/Keychains' do
        expected_command = "security import item.path -k '#{Dir.home}/Library/Keychains/login.keychain' -P #{''.shellescape} -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/productbuild -T /usr/bin/productsign 1> /dev/null"

        # this command is also sent on macOS Sierra and we need to allow it or else the test will fail
        expected_partition_command = "security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k #{''.shellescape} #{Dir.home}/Library/Keychains/login.keychain 1> /dev/null"

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with("#{Dir.home}/Library/Keychains/login.keychain").and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with('item.path').and_return(true)

        expect(Open3).to receive(:popen3).with(expected_command).and_yield("", "", "", thread)
        expect(Open3).to receive(:popen3).with(expected_partition_command)

        Match::Utils.import('item.path', 'login.keychain', password: '')
      end

      it 'treats a keychain name it cannot find in ~/Library/Keychains as the full keychain path' do
        tmp_path = Dir.mktmpdir
        keychain = "#{tmp_path}/my/special.keychain"
        expected_command = "security import item.path -k '#{keychain}' -P #{''.shellescape} -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/productbuild -T /usr/bin/productsign 1> /dev/null"

        # this command is also sent on macOS Sierra and we need to allow it or else the test will fail
        expected_partition_command = "security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k #{''.shellescape} #{keychain} 1> /dev/null"

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with(keychain).and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with('item.path').and_return(true)

        expect(Open3).to receive(:popen3).with(expected_command).and_yield("", "", "", thread)
        expect(Open3).to receive(:popen3).with(expected_partition_command)

        Match::Utils.import('item.path', keychain, password: '')
      end

      it 'shows a user error if the keychain path cannot be resolved' do
        allow(File).to receive(:exist?).and_return(false)

        expect do
          Match::Utils.import('item.path', '/my/special.keychain')
        end.to raise_error(/Could not locate the provided keychain/)
      end

      it "tries to find the macOS Sierra keychain too" do
        expected_command = "security import item.path -k '#{Dir.home}/Library/Keychains/login.keychain-db' -P #{''.shellescape} -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/productbuild -T /usr/bin/productsign 1> /dev/null"

        # this command is also sent on macOS Sierra and we need to allow it or else the test will fail
        expected_partition_command = "security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k #{''.shellescape} #{Dir.home}/Library/Keychains/login.keychain-db 1> /dev/null"

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with("#{Dir.home}/Library/Keychains/login.keychain-db").and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with("item.path").and_return(true)

        expect(Open3).to receive(:popen3).with(expected_command).and_yield("", "", "", thread)
        expect(Open3).to receive(:popen3).with(expected_partition_command)

        Match::Utils.import('item.path', "login.keychain")
      end

      describe "keychain_password" do
        it 'prompts for keychain password when none given and not in keychain' do
          expected_command = "security import item.path -k '#{Dir.home}/Library/Keychains/login.keychain' -P #{''.shellescape} -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/productbuild -T /usr/bin/productsign 1> /dev/null"

          # this command is also sent on macOS Sierra and we need to allow it or else the test will fail
          expected_partition_command = "security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k #{'user_entered'.shellescape} #{Dir.home}/Library/Keychains/login.keychain 1> /dev/null"

          allow(Security::InternetPassword).to receive(:find).and_return(nil)
          allow(FastlaneCore::UI).to receive(:interactive?).and_return(true)

          expect(FastlaneCore::Helper).to receive(:ask_password).and_return('user_entered')
          expect(Security::InternetPassword).to receive(:add).with('fastlane_keychain_login', anything, 'user_entered')

          allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
          allow(File).to receive(:file?).and_return(false)
          expect(File).to receive(:file?).with("#{Dir.home}/Library/Keychains/login.keychain").and_return(true)
          allow(File).to receive(:exist?).and_return(false)
          expect(File).to receive(:exist?).with('item.path').and_return(true)

          expect(Open3).to receive(:popen3).with(expected_command).and_yield("", "", "", thread)
          expect(Open3).to receive(:popen3).with(expected_partition_command)

          Match::Utils.import('item.path', 'login.keychain')
        end

        it 'find keychain password in keychain when none given' do
          expected_command = "security import item.path -k '#{Dir.home}/Library/Keychains/login.keychain' -P #{''.shellescape} -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/productbuild -T /usr/bin/productsign 1> /dev/null"

          # this command is also sent on macOS Sierra and we need to allow it or else the test will fail
          expected_partition_command = "security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k #{'from_keychain'.shellescape} #{Dir.home}/Library/Keychains/login.keychain 1> /dev/null"

          item = double
          allow(item).to receive(:password).and_return('from_keychain')
          allow(Security::InternetPassword).to receive(:find).and_return(item)

          allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
          allow(File).to receive(:file?).and_return(false)
          expect(File).to receive(:file?).with("#{Dir.home}/Library/Keychains/login.keychain").and_return(true)
          allow(File).to receive(:exist?).and_return(false)
          expect(File).to receive(:exist?).with('item.path').and_return(true)

          expect(Open3).to receive(:popen3).with(expected_command).and_yield("", "", "", thread)
          expect(Open3).to receive(:popen3).with(expected_partition_command)

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
