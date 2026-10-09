describe FastlaneCore::KeychainImporter do
  describe ".resolve_keychain_password" do
    let(:keychain_path) { File.join(Dir.home, "Library", "Keychains", "signing.keychain-db") }

    before { FastlaneCore::StoredPasswords.reset_warnings! }

    def resolve_entered_password(env)
      allow(Security::InternetPassword).to receive(:find).and_return(nil)
      allow(FastlaneCore::UI).to receive(:interactive?).and_return(true)
      allow(FastlaneCore::Helper).to receive(:ask_password).and_return("entered password")
      FastlaneSpec::Env.with_env_values(env) do
        expect(described_class.resolve_keychain_password(keychain_path)).to eq("entered password")
      end
    end

    it "does not store the entered password unless asked to" do
      expect(Security::InternetPassword).not_to receive(:add)
      resolve_entered_password("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => nil, "FASTLANE_DONT_STORE_PASSWORD" => nil)
    end

    it "stores the entered password when FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN is set" do
      expect(Security::InternetPassword).to receive(:add).with("fastlane_keychain_signing", "", "entered password")
      resolve_entered_password("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1", "FASTLANE_DONT_STORE_PASSWORD" => nil)
    end

    it "does not store the entered password when FASTLANE_DONT_STORE_PASSWORD is set, even when asked to" do
      expect(Security::InternetPassword).not_to receive(:add)
      resolve_entered_password("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1", "FASTLANE_DONT_STORE_PASSWORD" => "1")
    end

    it "warns once that a stored password was read" do
      allow(Security::InternetPassword).to receive(:find).with(server: "fastlane_keychain_signing").and_return(double("item", password: "stored password"))
      allow(FastlaneCore::UI).to receive(:important)
      expect(FastlaneCore::UI).to receive(:important).with(/any program running as you can read/).once

      expect(described_class.resolve_keychain_password(keychain_path)).to eq("stored password")
      described_class.resolve_keychain_password(keychain_path)
    end
  end
end
