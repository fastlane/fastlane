describe Match do
  describe Match::Nuke do
    context "#profile_types" do
      it "profile types for appstore" do
        match_nuke = Match::Nuke.new
        profiles = match_nuke.send(:profile_types, "appstore")

        expect(profiles).to eq([
                                 Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_STORE,
                                 Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_STORE,
                                 Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_STORE,
                                 Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_STORE
                               ])
      end

      it "profile types for development" do
        match_nuke = Match::Nuke.new
        profiles = match_nuke.send(:profile_types, "development")

        expect(profiles).to eq([
                                 Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_DEVELOPMENT,
                                 Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DEVELOPMENT,
                                 Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_DEVELOPMENT,
                                 Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DEVELOPMENT
                               ])
      end

      it "profile types for enterprise with Apple ID auth" do
        match_nuke = Match::Nuke.new
        profiles = match_nuke.send(:profile_types, "enterprise")

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

        match_nuke = Match::Nuke.new
        profiles = match_nuke.send(:profile_types, "enterprise")

        expect(profiles).to eq([
                                 Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_INHOUSE,
                                 Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_INHOUSE
                               ])
      end

      it "profile types for adhoc" do
        match_nuke = Match::Nuke.new
        profiles = match_nuke.send(:profile_types, "adhoc")

        expect(profiles).to eq([
                                 Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_ADHOC,
                                 Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_ADHOC
                               ])
      end

      it "profile types for developer_id" do
        match_nuke = Match::Nuke.new
        profiles = match_nuke.send(:profile_types, "developer_id")

        expect(profiles).to eq([
                                 Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DIRECT,
                                 Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DIRECT
                               ])
      end
    end
  end
end
