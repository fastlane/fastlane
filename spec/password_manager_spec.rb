require 'ios_deploy_kit/password_manager'

describe IosDeployKit do
  describe IosDeployKit::PasswordManager do
    let (:username) { "test@example123.com" }
    let (:password) { "somethingFancy123$" }

    before do
      ENV["IOS_DEPLOY_KIT_USER"] = username
      ENV["IOS_DEPLOY_KIT_PASSWORD"] = password
    end

    describe "#username" do
      it "uses the environment variable if given" do
        expect(IosDeployKit::PasswordManager.new.username).to eq(username)
      end
    end

    describe "#password" do
      it "uses the environment variable if given" do
        expect(IosDeployKit::PasswordManager.new.password).to eq(password)
      end
    end
  end
end