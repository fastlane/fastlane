describe Deliver do
  describe Deliver::IpaUploader do
    let (:apple_id) { 794902327 }
    let (:app_identifier) { 'net.sunapps.1' }

    before do
      @app = Deliver::App.new(apple_id: apple_id, app_identifier: app_identifier)
    end

    describe "#init" do
      it "raises an exception, when ipa file could not be found" do
        expect {
          Deliver::IpaUploader.new(@app, "/tmp", "./nonExistent.ipa", true)
        }.to raise_error("IPA on path './nonExistent.ipa' not found")
      end

      it "raises an exception, when ipa file is not an ipa file" do
        expect {
          Deliver::IpaUploader.new(@app, "/tmp", "./spec/fixtures/screenshots/iPhone4.png", true)
        }.to raise_error("IPA on path './spec/fixtures/screenshots/iPhone4.png' is not a valid IPA file")
      end
    end

    describe "after init" do
      before do
        @uploader = Deliver::IpaUploader.new(@app, "/tmp", "./spec/fixtures/ipas/Example1.ipa", false)
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

    describe "#start" do
      it "properly loads and stores the ipa when it's valid" do
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

        uploader = Deliver::IpaUploader.new(@app, "/tmp", "./spec/fixtures/ipas/Example1.ipa", false)

        expect(uploader.app.apple_id).to eq(apple_id)
        
        expect(uploader.upload!).to eq(true)
        
        expect(uploader.fetch_value("//x:size").first.content.to_i).to eq(2056240)
        expect(uploader.fetch_value("//x:checksum").first.content).to eq("094c6abbfd3a22e7e0ebc85c5f650882")
        expect(uploader.fetch_value("//x:file_name").first.content).to eq("304c8f3176463c89c28fe3a8ea6c726b.ipa")

        content = File.read("/tmp/#{apple_id}.itmsp/metadata.xml").to_s
        expect(content).to eq(File.read("./spec/fixtures/metadata/ipa_result2.xml").to_s)
      end
    end 
  end
end