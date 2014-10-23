require 'pry'
describe Deliver do
  describe Deliver::Deliverer do

    describe "#initialize" do
      describe "Different Deliverfiles" do
        it "raises an error when file was not found" do
          expect {
            Deliver::Deliverer.new(nil)
          }.to raise_exception "Deliverfile not found at path './Deliverfile'"
        end

        it "raises an error if some key information is missing" do
          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingAppVersion")
          }.to raise_exception("You have to pass a valid version number using the Deliver file.")

          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingIdentifier")
          }.to raise_exception("You have to pass a valid app identifier using the Deliver file.")

          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingLanguage")
          }.to raise_exception(Deliver::Deliverfile::Deliverfile::DSL::SPECIFY_LANGUAGE_FOR_VALUE)
        end

        it "throws an exception when both ipa and beta_ipa are given" do
          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileDuplicateIpa")
          }.to raise_exception("You can not set both ipa and beta_ipa in one file. Either it's a beta build or a release build")
        end

        describe "Valid Deliverfiles" do
          before do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")
          end

          it "successfully loads the Deliverfile if it's valid" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            meta = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileSimple")

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
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            meta = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMixed")

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

          it "Uploads all the available screenshots" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
            deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileScreenshots")
            screenshots = deliv.app.metadata.fetch_value("//x:software_screenshot")
            expect(screenshots.count).to eq(9)

            screenshots_path = "spec/fixtures/packages/#{deliv.app.apple_id}.itmsp/*.png"
            expect(Dir.glob(screenshots_path).count).to equal(screenshots.count)
            Dir.glob(screenshots_path) do |file|
              File.delete(file)
            end
          end

          it "Does not require an app version, when an ipa is given" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # the ipa file
            deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileNoVersion")

            expect(deliv.app.apple_id).to eq(464686641)
            expect(deliv.app.app_identifier).to eq('at.felixkrause.iTanky')
            expect(deliv.deploy_information.values.count).to eq(2)
          end

          it "Let's the user specify which languages should be supported" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # the ipa file

            deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileLocales")
            expect(deliv.app.metadata.fetch_value("//x:locale").count).to eq(5)
            expect(deliv.app.metadata.fetch_value("//x:title").count).to eq(5)
          end

          describe "Test Deliver Callback blocks" do
            before do
              path = "/tmp/"
              @tests_path = "#{path}/deliver_unit_tests.txt"
              @success_path = "#{path}/deliver_success.txt"
              @error_path = "#{path}/deliver_error.txt"
              paths = [@tests_path, @success_path, @error_path]

              # Delete files from previous runs
              paths.each do |current|
                File.delete(current) if File.exists?current
              end
            end

            it "Successful" do
              expect(File.exists?@tests_path).to eq(false)
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # the ipa file
              deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacks")
              expect(File.exists?@tests_path).to eq(true)
              expect(File.exists?@success_path).to eq(true)
              expect(File.exists?@error_path).to eq(false)
            end

            it "Error on ipa upload" do
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_invalid.txt") # the ipa file
              deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacks")
              expect(File.exists?@tests_path).to eq(true)
              expect(File.exists?@success_path).to eq(false)
              expect(File.exists?@error_path).to eq(true)
            end

            it "Error on app metadata upload" do
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_invalid.txt")
              deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacks")
              expect(File.exists?@tests_path).to eq(true)
              expect(File.exists?@success_path).to eq(false)
              expect(File.exists?@error_path).to eq(true)
            end

            it "Error on unit tests" do
              expect(File.exists?@tests_path).to eq(false)
              deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacksFailingTests")
              expect(File.exists?@tests_path).to eq(true)
              expect(File.exists?@success_path).to eq(false)
              expect(File.exists?@error_path).to eq(true)
            end

            it "Error on unit tests with no error block raises an exception" do
              expect{
                deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacksNoErrorBlock")
              }.to raise_exception("Unit tests failed. Got result: 'false'. Need 'true' or 1 to succeed.")
            end
          end
        end

        it "raises an exception if app identifier of ipa does not match the given one" do
          expect {
            meta = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileWrongIdentifier")
          }.to raise_exception("App Identifier of IPA does not match with the given one (net.sunapps.321 != at.felixkrause.iTanky)")
        end

        it "raises an exception if app version of ipa does not match the given one" do
          expect {
            meta = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileWrongVersion")
          }.to raise_exception("App Version of IPA does not match with the given one (128378973 != 1.0)")
        end
      end
    end

    describe "#initialize with hash" do
      it "raises an exception when some information is missing" do
        expect {
          @meta = Deliver::Deliverer.new(nil, hash: {})
        }.to raise_exception("You have to pass a valid app identifier using the Deliver file.")
      end

      it "works with valid data" do
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # metadata
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # ipa file

        version = '1.0'
        identifier = 'at.felixkrause.iTanky'
        ipa = "spec/fixtures/ipas/Example1.ipa"

        @meta = Deliver::Deliverer.new(nil, hash: {
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