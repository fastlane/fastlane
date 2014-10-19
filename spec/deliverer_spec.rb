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

        describe "Valid Deliverfiles" do
          before do
            IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")
          end

          it "successfully loads the Deliverfile if it's valid" do
            IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileSimple")

            thanks_for_facebook = "Thanks for using Facebook! To make our app better for you, we bring updates to the App Store every 4 weeks."

            expect(meta.app.app_identifier).to eq("net.sunapps.54")
            expect(meta.deploy_information[:version]).to eq("943.0")
            expect(meta.deploy_information[:changelog]).to eq({
              'en-US' => thanks_for_facebook
            })

            # Stored in XML file
            expect(meta.app.metadata.fetch_value("//x:version").first['string']).to eq("943.0")
            expect(meta.app.metadata.fetch_value("//x:version_whats_new").count).to eq(1) # one language only
            expect(meta.app.metadata.fetch_value("//x:version_whats_new").first.content).to eq(thanks_for_facebook)
          end

          it "Sets all the available metadata" do
            IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMixed")

            expect(meta.app.app_identifier).to eq("net.sunapps.54")

            expect(meta.deploy_information[:changelog]).to eq({"en-US"=>"Thanks for using this app"})

            expect(meta.deploy_information[:version]).to eq("943.0")
            expect(meta.deploy_information[:description]).to eq({"en-US"=>"App description"})
            expect(meta.deploy_information[:privacy_url].values.first).to eq("http://privacy.sunapps.net")
            expect(meta.deploy_information[:marketing_url].values.first).to eq("http://www.sunapps.net")
            expect(meta.deploy_information[:support_url].values.first).to eq("http://support.sunapps.net")
            expect(meta.deploy_information[:title]).to eq({"en-US"=>"The ultimate iPhone app"})
            expect(meta.deploy_information[:keywords]).to eq({"en-US"=>["keyword1", "something", "else"]})
          end

          it "raises an exception when the versions do not match" do
            expect {
              IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileVersionMismatchPackage")
            }.to raise_exception("Version mismatch: on iTunesConnect the latest version is '943.0', you specified '0.9.0'")
          end

          it "Uploads all the available screenshots" do
            IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
            deliv = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileScreenshots")
            screenshots = deliv.app.metadata.fetch_value("//x:software_screenshot")
            expect(screenshots.count).to eq(9)

            screenshots_path = "spec/fixtures/packages/#{deliv.app.apple_id}.itmsp/*.png"
            expect(Dir.glob(screenshots_path).count).to equal(screenshots.count)
            Dir.glob(screenshots_path) do |file|
              File.delete(file)
            end
          end

          it "Does not require an app version, when an ipa is given" do
            IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
            IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # the ipa file
            deliv = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileNoVersion")
            expect(deliv.app.apple_id).to eq(464686641)
            expect(deliv.app.app_identifier).to eq('at.felixkrause.iTanky')
            expect(deliv.deploy_information.values.count).to eq(2)
          end
        end

        it "raises an exception if app identifier of ipa does not match the given one" do
          expect {
            meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileWrongIdentifier")
          }.to raise_exception("App Identifier of IPA does not match with the given one (net.sunapps.321 != at.felixkrause.iTanky)")
        end

        it "raises an exception if app version of ipa does not match the given one" do
          expect {
            meta = IosDeployKit::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileWrongVersion")
          }.to raise_exception("App Version of IPA does not match with the given one (128378973 != 1.0)")
        end
      end
    end

    describe "#initialize with hash" do
      it "raises an exception when some information is missing" do
        expect {
          @meta = IosDeployKit::Deliverer.new(nil, {})
        }.to raise_exception("You have to pass a valid app identifier using the Deliver file.")
      end

      it "works with valid data" do
        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")
        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # metadata
        IosDeployKit::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # ipa file

        version = '1.0'
        identifier = 'at.felixkrause.iTanky'
        ipa = "spec/fixtures/ipas/Example1.ipa"

        @meta = IosDeployKit::Deliverer.new(nil, {
          app_identifier: identifier,
          version: version,
          ipa: ipa
        })

        expect(@meta.deploy_information[:version]).to eq(version)
        expect(@meta.deploy_information[:app_identifier]).to eq(identifier)
        expect(@meta.deploy_information[:ipa]).to eq(ipa)
      end
    end
  end
end