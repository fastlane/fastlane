describe FastlaneCore::StoredPasswords do
  before { described_class.reset_warnings! }

  describe ".store?" do
    it "is false unless FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN is set" do
      FastlaneSpec::Env.with_env_values("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => nil) do
        expect(described_class.store?).to be(false)
      end
    end

    it "is true when FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN is set" do
      FastlaneSpec::Env.with_env_values("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1") do
        expect(described_class.store?).to be(true)
      end
    end
  end

  describe ".read_warning" do
    it "warns once per keychain item" do
      warning = described_class.read_warning("deliver.user@example.com", what: "the password", remove_with: "remove", instead: "use FASTLANE_PASSWORD")
      expect(warning.first).to include("deliver.user@example.com")
      expect(described_class.read_warning("deliver.user@example.com", what: "the password", remove_with: "remove", instead: "use FASTLANE_PASSWORD")).to be_nil
      expect(described_class.read_warning("match_repo", what: "the passphrase", remove_with: "remove", instead: "use MATCH_PASSWORD")).not_to be_nil
    end
  end
end
