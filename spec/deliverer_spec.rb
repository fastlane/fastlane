describe IosDeployKit do
  describe IosDeployKit::Deliverer do

    describe "#initialize" do
      describe "Different Deliverfiles" do
        it "raises an error when file was not found" do
          expect {
            IosDeployKit::Deliverer.new(nil)
          }.to raise_exception "Deliverfile not found at path './Deliverfile'"
        end

        it "raises an error if some key information is missing" do
          expect {
            IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingAppVersion")
          }.to raise_exception("You have to pass a valid version number using the Deliver file.")

          expect {
            IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingIdentifier")
          }.to raise_exception("You have to pass a valid app identifier using the Deliver file.")

          expect {
            IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingLanguage")
          }.to raise_exception(IosDeployKit::Deliverfile::Deliverfile::DSL::SPECIFY_LANGUAGE_FOR_VALUE)
        end

        it "successfully loads the Deliverfile if it's valid", felix: true do
          meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileSimple")

          expect(meta.deploy_information[IosDeployKit::Deliverer::ValKey::APP_VERSION]).to eq("943.0")
          # meta.app.app_identifier.should eq("com.facebook.Facebook") TODO
          expect(meta.app.app_identifier).to eq("net.sunapps.54")
          expect(meta.deploy_information[:version]).to eq("943.0")
          expect(meta.deploy_information[:changelog]).to eq({
            'en-US' => "Thanks for using Facebook! To make our app better for you, we bring updates to the App Store every 4 weeks."
          })

          # meta.app.metadata.fetch_value("//x:version").first['string'].should eq("943.0") TODO: works when properly mocking everything
          expect(meta.app.metadata.fetch_value("//x:version_whats_new").first.content).to eq("Thanks for using Facebook! To make our app better for you, we bring updates to the App Store every 4 weeks.")
          # meta.app.metadata.fetch_value("//x:version_whats_new").count.should eq(1) # one language only
        end

        it "Sets all the available metadata", felix: true do
          meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMixed")

          expect(meta.app.app_identifier).to eq("net.sunapps.54")

          expect(meta.deploy_information[:changelog]).to eq({
            "de-DE" => "Danke für das Lesen dieses Tests", 
            "en-US" => "Thanks for using this app"
          })

          expect(meta.deploy_information[:version]).to eq("143.4.123")
          expect(meta.deploy_information[:description]).to eq({"de-DE"=>"App Beschreibung", "en-US"=>"App description"})
          expect(meta.deploy_information[:privacy_url].values.first).to eq("http://privacy.sunapps.net")
          expect(meta.deploy_information[:marketing_url].values.first).to eq("http://www.sunapps.net")
          expect(meta.deploy_information[:support_url].values.first).to eq("http://support.sunapps.net")
          expect(meta.deploy_information[:title]).to eq({"de-DE"=>"Die ultimative iPhone App", "en-US"=>"The ultimate iPhone app"})
          expect(meta.deploy_information[:keywords]).to eq({"de-DE"=>["keyword1", "something", "else"], "en-US"=>["random", "values", "are", "here"]})
        end

        it "Uploads all the available screenshots", felix: true do
          meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileScreenshots")
          # TODO: test even more
        end

        it "raises an exception if app identifier of ipa does not match the given one" do
          expect {
            meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileWrongIdentifier")
          }.to raise_exception("App Identifier of IPA does not mtach with the given one (net.sunapps.321 != at.felixkrause.iTanky)")
        end

        it "raises an exception if app version of ipa does not match the given one" do
          expect {
            meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileWrongVersion")
          }.to raise_exception("App Version of IPA does not mtach with the given one (128378973 != 1.0)")
        end

        it "works with a super simple Deliverfile" do
          # meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileSimplest")
          
        end
      end
    end

    describe "#initialize with hash", felix: true do
      it "raises an exception when some information is missing" do
        expect {
          @meta = IosDeployKit::Deliverer.new(nil, {})
        }.to raise_exception("You have to pass a valid app identifier using the Deliver file.")
      end

      # it "works with valid data" do
      #   version = '1.0'
      #   identifier = 'at.felixkrause.iTanky'
      #   ipa = "spec/fixtures/ipas/Example1.ipa"

      #   @meta = IosDeployKit::Deliverer.new(nil, {
      #     app_identifier: identifier,
      #     version: version,
      #     ipa: ipa
      #   })

      #   @meta.deploy_information[:version].should eq(version)
      #   @meta.deploy_information[:app_identifier].should eq(identifier)
      #   @meta.deploy_information[:ipa].should eq(ipa)
      # end
    end

    describe "#set_new_value", felix: true do
      before do
        @hash = {
          app_identifier: "net.sunapps.54",
          version: "1.3",
          description: { 'de-DE' => "Something" }
        }
        @meta = IosDeployKit::Deliverer.new(nil, @hash)
      end

      it "has the correct information set based on the given hash", currently: true do
        expect(@meta.deploy_information[:app_identifier]).to eq(@hash[:app_identifier])
        expect(@meta.deploy_information[:version]).to eq(@hash[:version])
        expect(@meta.deploy_information[:description]).to eq(@hash[:description])
      end

      it "raises an exception when usig an invalid key" do
        expect {
          @meta.set_new_value("invalid_key", "value")
        }.to raise_exception("Invalid key 'invalid_key', must be contained in Deliverer::ValKey.")
      end

      it "properly updates the key", currently: true do
        ipa_value = "./something.ipa"

        @meta.set_new_value(:ipa, ipa_value)
        expect(@meta.deploy_information[:ipa]).to eq(ipa_value)
      end
    end
  end
end