describe IosDeployKit do
  describe IosDeployKit::ItunesTransporter do
    before do
      @app = IosDeployKit::App.new(apple_id: 284882215, app_identifier: 'com.facebook.Facebook')
    end

    describe "#download" do
      it "throws an exception when invalid parameter is given" do
        expect {
          IosDeployKit::ItunesTransporter.new.download(123)
        }.to raise_error "No valid IosDeployKit::App given"
      end

      it "invalid login information" do
        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/download_invalid_apple_id.txt")
        expect {
          expect(IosDeployKit::ItunesTransporter.new("email@email.com", "login").download(@app)).to eq(true)
        }.to raise_error(/.*This Apple ID has been locked for security reasons.*/)
      end
    end

    describe "#upload" do
      it "properly uploads the package file" do
        @app.apple_id = 878567776

        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")

        FileUtils.cp_r "./spec/fixtures/example2.itmsp/", '/tmp'

        path = "/tmp/example2.itmsp"

        @app.set_metadata_directory(path)

        @app.metadata # download & parse the latest metadata

        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
        expect(@app.upload_metadata!).to eq(true)


        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
        @ipa = IosDeployKit::IpaUploader.new(@app, '/tmp/', "./spec/fixtures/ipas/Example1.ipa")
        expect(@ipa.upload!).to eq(true)

        # Verify the example2/metadata.xml is correct
        content = File.read("/tmp/#{@app.apple_id}.itmsp/metadata.xml").to_s
        expect(content).to eq(File.read("./spec/fixtures/metadata/ipa_result.xml").to_s)

        FileUtils.rm_rf(path)
      end
    end
  end
end