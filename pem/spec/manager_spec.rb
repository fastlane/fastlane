describe PEM do
  describe PEM::Manager do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"

      pem_stub_spaceship
    end

    before :all do
      FileUtils.mkdir("tmp")
    end

    it "Successful run" do
      pem_stub_spaceship_cert(platform: 'ios')

      options = { app_identifier: "com.krausefx.app", generate_p12: false }
      PEM.config = FastlaneCore::Configuration.create(PEM::Options.available_options, options)
      PEM::Manager.start

      expect(File.exist?("production_com.krausefx.app_ios.pem")).to eq(true)
      expect(File.exist?("production_com.krausefx.app_ios.pkey")).to eq(true)
    end

    it "Successful run with output_path for ios platform" do
      pem_stub_spaceship_cert(platform: 'ios')

      options = { app_identifier: "com.krausefx.app", generate_p12: false, output_path: "tmp/" }
      PEM.config = FastlaneCore::Configuration.create(PEM::Options.available_options, options)
      PEM::Manager.start

      expect(File.exist?("tmp/production_com.krausefx.app_ios.pem")).to eq(true)
      expect(File.exist?("tmp/production_com.krausefx.app_ios.pkey")).to eq(true)
      expect(File.exist?("tmp/production_com.krausefx.app_ios.p12")).to eq(false)
    end

    it "Successful run with output_path for macos platform" do
      pem_stub_spaceship_cert(platform: 'macos')

      options = { app_identifier: "com.krausefx.app", generate_p12: false, output_path: "tmp/", platform: 'macos' }
      PEM.config = FastlaneCore::Configuration.create(PEM::Options.available_options, options)
      PEM::Manager.start

      expect(File.exist?("tmp/production_com.krausefx.app_macos.pem")).to eq(true)
      expect(File.exist?("tmp/production_com.krausefx.app_macos.pkey")).to eq(true)
      expect(File.exist?("tmp/production_com.krausefx.app_macos.p12")).to eq(false)
    end

    after :all do
      FileUtils.rm_r("tmp")
      File.delete("production_com.krausefx.app_ios.pem")
      File.delete("production_com.krausefx.app_ios.pkey")

      ENV.delete("DELIVER_USER")
      ENV.delete("DELIVER_PASSWORD")
    end
  end
end
