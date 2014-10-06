describe IosDeployKit do
  describe IosDeployKit::IpaUploader do
    let (:apple_id) { 794902327 }
    let (:app_identifier) { 'net.sunapps.1' }

    before do
      @app = IosDeployKit::App.new(apple_id, app_identifier)
    end

    describe "#init" do
      it "raises an exception, when ipa file could not be found" do
        expect {
          IosDeployKit::IpaUploader.new(@app, "/tmp", "./nonExistent.ipa")
        }.to raise_error("IPA on path './nonExistent.ipa' not found")
      end

      it "raises an exception, when ipa file is not an ipa file" do
        expect {
          IosDeployKit::IpaUploader.new(@app, "/tmp", "./spec/fixtures/screenshots/iPhone4.png")
        }.to raise_error("IPA on path './spec/fixtures/screenshots/iPhone4.png' is not a valid IPA file")
      end
    end

    describe "after init" do
      before do
        @uploader = IosDeployKit::IpaUploader.new(@app, "/tmp", "./spec/fixtures/ipas/Example1.ipa")
      end

      describe "#fetch_app_identifier" do
        it "returns the valid identifier based on the Info.plist file" do
          expect(@uploader.fetch_app_identifier).to eq("at.felixkrause.iTanky")
        end
      end

      describe "#fetch_app_version" do
        it "returns the valid version based on the Info.plist file" do
          expect(@uploader.fetch_app_version).to eq("1.0")
        end
      end
    end

    # describe "#start", current: true do
    #   it "properly loads and stores the ipa when it's valid" do
    #     # uploader = IosDeployKit::IpaUploader.new(@app, "/tmp", "./spec/fixtures/ipas/Example1.ipa")
    #     uploader = IosDeployKit::IpaUploader.new(@app, "/tmp", "./integration/example1/example1.ipa")
    #     uploader.upload!
    #   end
    # end 
  end
end