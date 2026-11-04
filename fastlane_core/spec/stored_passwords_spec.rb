describe FastlaneCore::StoredPasswords do
  before { described_class.reset_warnings! }

  describe ".store?" do
    it "is false unless FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN is set" do
      FastlaneSpec::Env.with_env_values("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => nil) do
        expect(described_class.store?).to be(false)
      end
    end

    it "is true when FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN is set" do
      FastlaneSpec::Env.with_env_values("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1", "FASTLANE_DONT_STORE_PASSWORD" => nil) do
        expect(described_class.store?).to be(true)
      end
    end

    it "is false when FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN is 0 or false" do
      ["0", "false"].each do |value|
        FastlaneSpec::Env.with_env_values("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => value, "FASTLANE_DONT_STORE_PASSWORD" => nil) do
          expect(described_class.store?).to be(false)
        end
      end
    end

    it "is false when FASTLANE_DONT_STORE_PASSWORD is set, even with FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" do
      FastlaneSpec::Env.with_env_values("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1", "FASTLANE_DONT_STORE_PASSWORD" => "1") do
        expect(described_class.store?).to be(false)
      end
    end

    it "treats any FASTLANE_DONT_STORE_PASSWORD value as set, even 0, as it always has" do
      FastlaneSpec::Env.with_env_values("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1", "FASTLANE_DONT_STORE_PASSWORD" => "0") do
        expect(described_class.store?).to be(false)
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
