describe IosDeployKit do
  describe IosDeployKit::ItunesTransporter do
    before do
      @app = IosDeployKit::App.new(apple_id: 284882215, app_identifier: 'com.facebook.Facebook')
    end

    describe "#download", felix: true do
      it "throws an exception when invalid parameter is given" do
        expect {
          IosDeployKit::ItunesTransporter.new.download(123)
        }.to raise_error "No valid IosDeployKit::App given"
      end

      it "downloads the package" do
        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/download_invalid_apple_id.txt")
        expect {
          expect(IosDeployKit::ItunesTransporter.new("email@email.com", "login").download(@app)).to eq(true)
        }.to raise_error(/.*This Apple ID has been locked for security reasons.*/)
      end

      it "works with correct inputs" do
        @app.apple_id = 878567776

        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")

        @app.metadata # download the latest metadata


        expect(@app.upload_metadata!).to eq(true)
      end
    end
  end
end