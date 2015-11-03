describe Cert do
  describe Cert::Runner do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"
    end

    it "Successful run" do
      stub_spaceship
      options = {}
      Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options)

      Cert::Runner.new.launch
      expect(ENV["CER_CERTIFICATE_ID"]).to eq("cert_id")
      expect(ENV["CER_FILE_PATH"]).to eq("#{Dir.pwd}/cert_id.cer")
      File.delete(ENV["CER_FILE_PATH"])
    end
  end
end
