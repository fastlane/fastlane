describe Sigh do
  describe Sigh::Manager do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"
    end

    let(:mock_base_client) { "fake api base client" }

    before(:each) do
      allow(mock_base_client).to receive(:login)
      allow(mock_base_client).to receive(:team_id).and_return('')

      allow(Spaceship::ConnectAPI::Provisioning::Client).to receive(:instance).and_return(mock_base_client)
    end

    it "Successful run" do
      sigh_stub_spaceship
      options = { app_identifier: "com.krausefx.app", skip_install: true, skip_certificate_verification: true }
      Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

      val = Sigh::Manager.start
      expect(val).to eq(File.expand_path("./AppStore_com.krausefx.app.mobileprovision"))
      File.delete(val)
    end

    it "Invalid profile not force run" do
      sigh_stub_spaceship(valid_profile = false, expect_create = true)
      options = { app_identifier: "com.krausefx.app", skip_install: true, skip_certificate_verification: true }
      Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

      val = Sigh::Manager.start
      expect(val).to eq(File.expand_path("./AppStore_com.krausefx.app.mobileprovision"))
      File.delete(val)
    end

    it "Invalid profile force run" do
      sigh_stub_spaceship(valid_profile = false, expect_create = true, expect_delete = true)
      options = { app_identifier: "com.krausefx.app", skip_install: true, skip_certificate_verification: true, force: true }
      Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

      val = Sigh::Manager.start
      expect(val).to eq(File.expand_path("./AppStore_com.krausefx.app.mobileprovision"))
      File.delete(val)
    end

    it "Existing profile fail on name taken" do
      sigh_stub_spaceship(valid_profile = true, expect_create = false, expect_delete = true, fail_delete = true)
      options = { app_identifier: "com.krausefx.app", skip_install: true, fail_on_name_taken: true, skip_certificate_verification: true, force: true }
      Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

      expect { Sigh::Manager.start }.to raise_error("The name 'com.krausefx.app AppStore' is already taken, and fail_on_name_taken is true")
    end
  end
end
