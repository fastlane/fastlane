describe PEM do
  describe PEM::Manager do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"

      stub_spaceship
    end

    it "Successful run" do
      options = { app_identifier: "com.krausefx.app", generate_p12: false }
      PEM.config = FastlaneCore::Configuration.create(PEM::Options.available_options, options)
      PEM::Manager.start

      expect(File.exist? "production_com.krausefx.app.pem").to eq(true)
      expect(File.exist? "production_com.krausefx.app.pkey").to eq(true)
    end

    after do
      File.delete("production_com.krausefx.app.pem")
      File.delete("production_com.krausefx.app.pkey")
    end
  end
end