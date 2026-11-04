describe PEM do
  describe PEM::Manager do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"

      pem_stub_spaceship
    end

    before :all do
      FileUtils.mkdir_p("tmp")
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

    it "Successful run for a VoIP Services certificate" do
      pem_stub_spaceship_cert(voip_push: true)

      options = { app_identifier: "com.krausefx.app", generate_p12: false, output_path: "tmp/", voip_push: true }
      PEM.config = FastlaneCore::Configuration.create(PEM::Options.available_options, options)
      PEM::Manager.start

      expect(File.exist?("tmp/voip_com.krausefx.app_ios.pem")).to eq(true)
      expect(File.exist?("tmp/voip_com.krausefx.app_ios.pkey")).to eq(true)
    end

    describe "key files" do
      let(:temp) { Dir.mktmpdir('fl_spec_pem') }
      let(:key_files) { %w(pem pkey p12).map { |ext| File.join(temp, "production_com.krausefx.app_ios.#{ext}") } }

      around do |example|
        old_umask = File.umask(0o022)
        begin
          example.run
        ensure
          File.umask(old_umask)
          FileUtils.rm_rf(temp)
        end
      end

      before do
        pem_stub_spaceship_cert(platform: 'ios')
        allow(OpenSSL::PKCS12).to receive(:create).and_return(double("p12", to_der: String.new("p12")))
        options = { app_identifier: "com.krausefx.app", generate_p12: true, p12_password: "secret", output_path: temp }
        PEM.config = FastlaneCore::Configuration.create(PEM::Options.available_options, options)
      end

      it "creates the .pem, .pkey and .p12 files readable only by their owner" do
        PEM::Manager.start
        expect(key_files.map { |path| File.stat(path).mode & 0o777 }).to eq([0o600] * 3) unless FastlaneCore::Helper.windows?
      end

      it "makes existing .pem, .pkey and .p12 files readable only by their owner" do
        key_files.each do |path|
          File.write(path, "old")
          File.chmod(0o644, path)
        end
        PEM::Manager.start
        expect(key_files.map { |path| File.read(path) }).not_to include("old")
        expect(key_files.map { |path| File.stat(path).mode & 0o777 }).to eq([0o600] * 3) unless FastlaneCore::Helper.windows?
      end
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
