require 'credentials_manager/password_manager'

describe CredentialsManager do
  describe CredentialsManager::PasswordManager do
    describe "Test environment" do
      let (:username) { "test@example123.com" }
      let (:password) { "somethingFancy123$" }

      before do
        ENV["DELIVER_USER"] = username
        ENV["DELIVER_PASSWORD"] = password
      end

      describe "#username" do
        it "uses the environment variable if given" do
          expect(CredentialsManager::PasswordManager.new.username).to eq(username)
        end
      end

      describe "#password" do
        it "uses the environment variable if given" do
          expect(CredentialsManager::PasswordManager.new.password).to eq(password)
        end
      end

      after do
        ENV.delete("DELIVER_USER")
        ENV.delete("DELIVER_PASSWORD")
      end
    end
  end
end
