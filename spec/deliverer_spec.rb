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

          meta.deploy_information[IosDeployKit::Deliverer::ValKey::APP_VERSION].should eq("943.0")
          # meta.app.app_identifier.should eq("com.facebook.Facebook") TODO
          meta.app.app_identifier.should eq("net.sunapps.54")
          meta.deploy_information[:version].should eq("943.0")
          meta.deploy_information[:changelog].should eq({
            'en-US' => "Thanks for using Facebook! To make our app better for you, we bring updates to the App Store every 4 weeks."
          })

          # meta.app.metadata.fetch_value("//x:version").first['string'].should eq("943.0") TODO: works when properly mocking everything
          meta.app.metadata.fetch_value("//x:version_whats_new").first.content.should eq("Thanks for using Facebook! To make our app better for you, we bring updates to the App Store every 4 weeks.")
          # meta.app.metadata.fetch_value("//x:version_whats_new").count.should eq(1) # one language only
        end

        it "Sets all the available metadata", felix: true do
          meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMixed")

          meta.app.app_identifier.should eq("net.sunapps.54")

          meta.deploy_information[:changelog].should eq({
            "de-DE" => "Danke für das Lesen dieses Tests", 
            "en-US" => "Thanks for using this app"
          })

          meta.deploy_information[:version].should eq("143.4.123")
          meta.deploy_information[:description].should eq({"de-DE"=>"App Beschreibung", "en-US"=>"App description"})
          meta.deploy_information[:privacy_url].values.first.should eq("http://privacy.sunapps.net")
          meta.deploy_information[:marketing_url].values.first.should eq("http://www.sunapps.net")
          meta.deploy_information[:support_url].values.first.should eq("http://support.sunapps.net")
          meta.deploy_information[:title].should eq({"de-DE"=>"Die ultimative iPhone App", "en-US"=>"The ultimate iPhone app"})
          meta.deploy_information[:keywords].should eq({"de-DE"=>["keyword1", "something", "else"], "en-US"=>["random", "values", "are", "here"]})
        end

        it "Uploads all the available screenshots", felix: true, now: true do
          meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileScreenshots")
          # TODO: test even more
        end

        it "raises an exception if app identifier of ipa does not match the given one" do
          expect {
            meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileWrongIdentifier")
          }.to raise_exception("App Identifier of IPA does not mtach with the given one")
        end

        it "raises an exception if app version of ipa does not match the given one" do
          expect {
            meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileWrongVersion")
          }.to raise_exception("App Version of IPA does not mtach with the given one")
        end

        it "works with a super simple Deliverfile" do
          meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileSimplest")
          
        end
      end
    end
  end
end