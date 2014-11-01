require 'deliver/password_manager'

describe Deliver do
  describe Deliver::PasswordManager, now: true do
    describe "Test environment" do
      let (:username) { "test@example123.com" }
      let (:password) { "somethingFancy123$" }

      before do
        ENV["DELIVER_USER"] = username
        ENV["DELIVER_PASSWORD"] = password
      end

      describe "#username" do
        it "uses the environment variable if given" do
          expect(Deliver::PasswordManager.new.username).to eq(username)
        end
      end

      describe "#password" do
        it "uses the environment variable if given" do
          expect(Deliver::PasswordManager.new.password).to eq(password)
        end
      end
    end
  end
end