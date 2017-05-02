describe Sigh do
  describe Sigh::Manager do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"
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
  end
end
