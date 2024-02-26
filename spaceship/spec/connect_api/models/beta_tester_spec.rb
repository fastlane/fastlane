describe Spaceship::ConnectAPI::BetaTester do
  before { Spaceship::Tunes.login }

  describe '#Spaceship::ConnectAPI' do
    it '#get_beta_testers' do
      response = Spaceship::ConnectAPI.get_beta_testers
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BetaTester)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.first_name).to eq("Cats")
      expect(model.last_name).to eq("AreCute")
      expect(model.email).to eq("email@email.com")
      expect(model.invite_type).to eq("EMAIL")
      expect(model.beta_tester_state).to eq("INSTALLED")
      expect(model.is_deleted).to eq(false)
      expect(model.last_modified_date).to eq("2024-01-21T20:52:18.921-08:00")
      expect(model.installed_cf_bundle_short_version_string).to eq("1.3.300")
      expect(model.installed_cf_bundle_version).to eq("1113")
      expect(model.remove_after_date).to eq("2024-04-20T00:00:00-07:00")
      expect(model.installed_device).to eq("iPhone14_7")
      expect(model.installed_os_version).to eq("17.2.1")
      expect(model.number_of_installed_devices).to eq(1.0)
      expect(model.latest_expiring_cf_bundle_short_version_string).to eq("1.3.300")
      expect(model.latest_expiring_cf_bundle_version_string).to eq("1113")
      expect(model.installed_device_platform).to eq("IOS")
      expect(model.latest_installed_device).to eq("iPhone14_7")
      expect(model.latest_installed_os_version).to eq("17.2.1")
      expect(model.latest_installed_device_platform).to eq("IOS")
    end
  end
end
