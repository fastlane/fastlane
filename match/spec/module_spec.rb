describe Match do
  context "#profile_types" do
    it "profile types for appstore" do
      profiles = Match.profile_types("appstore")

      expect(profiles).to eq([
                               Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_STORE,
                               Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_STORE,
                               Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_STORE,
                               Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_STORE
                             ])
    end

    it "profile types for development" do
      profiles = Match.profile_types("development")

      expect(profiles).to eq([
                               Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_DEVELOPMENT,
                               Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DEVELOPMENT,
                               Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_DEVELOPMENT,
                               Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DEVELOPMENT
                             ])
    end

    it "profile types for enterprise with Apple ID auth" do
      profiles = Match.profile_types("enterprise")

      expect(profiles).to eq([
                               Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_INHOUSE,
                               Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_INHOUSE,
                               Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_INHOUSE,
                               Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_INHOUSE
                             ])
    end

    it "profile types for enterprise with API Key auth" do
      token = double("mock_token")
      allow(Spaceship::ConnectAPI).to receive(:token).and_return(token)

      profiles = Match.profile_types("enterprise")

      expect(profiles).to eq([
                               Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_INHOUSE,
                               Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_INHOUSE
                             ])
    end

    it "profile types for adhoc" do
      profiles = Match.profile_types("adhoc")

      expect(profiles).to eq([
                               Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_ADHOC,
                               Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_ADHOC
                             ])
    end

    it "profile types for developer_id" do
      profiles = Match.profile_types("developer_id")

      expect(profiles).to eq([
                               Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DIRECT,
                               Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DIRECT
                             ])
    end
  end
end
