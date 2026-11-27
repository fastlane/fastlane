describe FastlaneCore::KeychainImporter do
  describe ".set_partition_list" do
    let(:keychain_path) { "/a b/test.keychain-db" }

    before do
      allow(Security::Keychain).to receive(:supports_key_partition_list?).and_return(true)
    end

    it "sets the partition list of the keychain with its password" do
      expect_any_instance_of(Security::Keychain).to receive(:set_key_partition_list) { |target, password| expect([target.filename, password]).to eq([keychain_path, "pa$$ word"]) }

      FastlaneCore::KeychainImporter.set_partition_list("cert.p12", keychain_path, keychain_password: "pa$$ word", output: false)
    end

    it "does nothing when security has no partition lists" do
      allow(Security::Keychain).to receive(:supports_key_partition_list?).and_return(false)
      expect_any_instance_of(Security::Keychain).not_to receive(:set_key_partition_list)

      FastlaneCore::KeychainImporter.set_partition_list("cert.p12", keychain_path, keychain_password: "", output: false)
    end

    ["security: SecKeychainItemSetAccessWithPassword: The user name or passphrase you entered is not correct.",
     "security: SecKeychainUnlock: The user name or passphrase you entered is not correct."].each do |message|
      it "forgets the stored keychain password and explains, for '#{message}'" do
        allow_any_instance_of(Security::Keychain).to receive(:set_key_partition_list).and_raise(Security::Error.new(1, "#{message}\n"))
        expect(Security::InternetPassword).to receive(:delete).with(server: "fastlane_keychain_test")
        allow(FastlaneCore::UI).to receive(:important)
        expect(FastlaneCore::UI).to receive(:important).with(/Check if you supplied the correct `keychain_password` for keychain: `#{Regexp.escape(keychain_path)}`/)

        FastlaneCore::KeychainImporter.set_partition_list("cert.p12", keychain_path, keychain_password: "wrong", output: false)
      end
    end

    it "reports any other failure" do
      allow_any_instance_of(Security::Keychain).to receive(:set_key_partition_list).and_raise(Security::Error.new(1, "security: SecItemCopyMatching: The specified item could not be found in the keychain.\n"))
      expect(Security::InternetPassword).not_to receive(:delete)
      expect(FastlaneCore::UI).to receive(:error).with("security: SecItemCopyMatching: The specified item could not be found in the keychain.")

      FastlaneCore::KeychainImporter.set_partition_list("cert.p12", keychain_path, keychain_password: "", output: false)
    end
  end
end
