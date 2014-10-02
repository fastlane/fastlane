describe IosDeployKit, now: true do
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

          meta.deploy_information[IosDeployKit::Deliverer::ValKey::APP_VERSION].should eq("143.4.123")
          # meta.app.app_identifier.should eq("com.facebook.Facebook")

          meta.deploy_information[:changelog].should eq({
            "de-DE" => "Danke für das Lesen dieses Tests", 
            "en-US" => "Thanks for using this app"
          })
        end
      end
    end
  end
end