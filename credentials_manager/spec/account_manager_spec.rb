describe CredentialsManager do
  describe CredentialsManager::AccountManager do
    let(:user) { "felix@krausefx.com" }
    let(:password) { "suchSecret" }

    it "allows passing user and password" do
      c = CredentialsManager::AccountManager.new(user: user, password: password)
      expect(c.user).to eq(user)
      expect(c.password).to eq(password)
    end

    it "loads the user from the new 'FASTLANE_USER' variable" do
      ENV['FASTLANE_USER'] = user
      c = CredentialsManager::AccountManager.new
      expect(c.user).to eq(user)
      ENV.delete('FASTLANE_USER')
    end

    it "loads the password from the new 'FASTLANE_PASSWORD' variable" do
      ENV['FASTLANE_PASSWORD'] = password
      c = CredentialsManager::AccountManager.new
      expect(c.password).to eq(password)
      ENV.delete('FASTLANE_PASSWORD')
    end

    it "still supports the legacy `DELIVER_USER` `DELIVER_PASSWORD` format" do
      ENV['DELIVER_USER'] = user
      ENV['DELIVER_PASSWORD'] = password
      c = CredentialsManager::AccountManager.new
      expect(c.user).to eq(user)
      expect(c.password).to eq(password)
      ENV.delete('DELIVER_USER')
      ENV.delete('DELIVER_PASSWORD')
    end

    it "fetches the Apple ID from the Appfile if available" do
      Dir.chdir("./credentials_manager/spec/fixtures/") do
        c = CredentialsManager::AccountManager.new
        expect(c.user).to eq("appfile@krausefx.com")
      end
    end

    it "automatically loads the password from the keychain" do
      ENV['FASTLANE_USER'] = user
      c = CredentialsManager::AccountManager.new

      dummy = Object.new
      expect(dummy).to receive(:password).and_return("Yeah! Pass!")

      expect(Security::InternetPassword).to receive(:find).with(server: "deliver.felix@krausefx.com").and_return(dummy)
      expect(c.password).to eq("Yeah! Pass!")
      ENV.delete('FASTLANE_USER')
    end

    it "loads the password from the keychain if empty password is stored by env" do
      ENV['FASTLANE_USER'] = user
      ENV['FASTLANE_PASSWORD'] = ''
      c = CredentialsManager::AccountManager.new

      dummy = Object.new
      expect(dummy).to receive(:password).and_return("Yeah! Pass!")

      expect(Security::InternetPassword).to receive(:find).with(server: "deliver.felix@krausefx.com").and_return(dummy)
      expect(c.password).to eq("Yeah! Pass!")
      ENV.delete('FASTLANE_USER')
      ENV.delete('FASTLANE_PASSWORD')
    end

    it "removes the Keychain item if the user agrees when the credentials are invalid" do
      expect(Security::InternetPassword).to receive(:delete).with(server: "deliver.felix@krausefx.com").and_return(nil)

      c = CredentialsManager::AccountManager.new(user: "felix@krausefx.com")
      expect(c).to receive(:ask_for_login).and_return(nil)
      c.invalid_credentials(force: true)
    end

    describe "storing the password in the keychain" do
      before { FastlaneCore::StoredPasswords.reset_warnings! }

      def ask_for_login_with(env)
        c = CredentialsManager::AccountManager.new(user: user, password: "entered password")
        allow(c).to receive(:mac?).and_return(true)
        FastlaneSpec::Env.with_env_values({ "FASTLANE_HIDE_LOGIN_INFORMATION" => "1", "FASTLANE_DONT_STORE_PASSWORD" => nil }.merge(env)) do
          c.send(:ask_for_login)
        end
      end

      it "does not store the entered password unless asked to" do
        expect(Security::InternetPassword).not_to receive(:add)
        ask_for_login_with("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => nil)
      end

      it "stores the entered password when FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN is set" do
        expect(Security::InternetPassword).to receive(:add).with("deliver.#{user}", user, "entered password").and_return(true)
        ask_for_login_with("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1")
      end

      it "does not store the entered password when FASTLANE_DONT_STORE_PASSWORD is set, even when asked to" do
        expect(Security::InternetPassword).not_to receive(:add)
        ask_for_login_with("FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1", "FASTLANE_DONT_STORE_PASSWORD" => "1")
      end

      it "warns once that a stored password was read, and how to remove it" do
        dummy = double("item", password: "stored password")
        allow(Security::InternetPassword).to receive(:find).with(server: "deliver.#{user}").and_return(dummy)

        expect do
          expect(CredentialsManager::AccountManager.new(user: user).password).to eq("stored password")
        end.to output(/any program running as you can read.*fastlane fastlane-credentials remove --username #{Regexp.escape(user)}/m).to_stdout
        expect do
          CredentialsManager::AccountManager.new(user: user).password
        end.not_to output(/any program running as you can read/).to_stdout
      end
    end

    it "defaults to 'deliver' as a prefix" do
      c = CredentialsManager::AccountManager.new(user: user)
      expect(c.server_name).to eq("deliver.#{user}")
    end

    it "supports custom prefixes" do
      prefix = "custom-prefix"
      c = CredentialsManager::AccountManager.new(user: user, prefix: prefix)
      expect(c.server_name).to eq("#{prefix}.#{user}")
    end
  end

  after(:each) do
    ENV.delete("FASTLANE_USER")
    ENV.delete("DELIVER_USER")
  end
end
