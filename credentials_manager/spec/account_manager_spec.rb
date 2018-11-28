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
