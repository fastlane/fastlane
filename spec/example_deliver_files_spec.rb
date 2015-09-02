describe Deliver do
  describe Deliver::Deliverer do
    describe "#initialize" do
      describe "Different Deliverfiles" do
        it "raises an error when file was not found" do
          error_path = File.expand_path("./Deliverfile")
          expect {
            Deliver::Deliverer.new(nil)
          }.to raise_exception "Deliverfile not found at path '#{error_path}'".red
        end

        it "raises an error if the language definition is missing" do
          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingLanguage")
          }.to raise_exception(Deliver::Deliverfile::Deliverfile::DSL::SPECIFY_LANGUAGE_FOR_VALUE.red)
        end

        it "raises an error if app identifier is missing" do
          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingIdentifier")
          }.to raise_exception("No App Identifier given")
        end

        it "throws an exception when block does not return anything" do
          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingValue")
          }.to raise_exception("You have to pass either a value or a block to the given method.".red)
        end

        it "throws an exception when no block is given for tests" do
          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMissingBlockForTests")
          }.to raise_exception("Value for unit_tests must be a Ruby block. Use 'unit_tests' do ... end.".red)
        end

        it "throws an exception when default_language is not on top of file" do
          expect {
            Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileDefaultLanguageNotOnTop")
          }.to raise_exception("'default_language' must be on the top of the Deliverfile.".red)
        end

        describe "Valid Deliverfiles" do
          before do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")
          end

          it "successfully loads the Deliverfile if it's valid" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            meta = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileSimple")

            thanks_for_facebook = "Thanks for using Facebook! To make our app better for you, we bring updates to the App Store every 4 weeks."

            expect(meta.deliver_process.app.app_identifier).to eq("net.sunapps.54")
            expect(meta.deliver_process.deploy_information[:version]).to eq("943.0")
            expect(meta.deliver_process.deploy_information[:changelog]).to eq({
              'en-US' => thanks_for_facebook
            })

            # Stored in XML file
            expect(meta.deliver_process.app.metadata.fetch_value("//x:version").first['string']).to eq("943.0")
            expect(meta.deliver_process.app.metadata.fetch_value("//x:version_whats_new").count).to eq(1) # one language only
            expect(meta.deliver_process.app.metadata.fetch_value("//x:version_whats_new").first.content).to eq(thanks_for_facebook)
            expect(meta.deliver_process.app.metadata.fetch_value("//x:wholesale_price_tier").first.content).to eq(0.to_s)
          end

          it "overwrites the config from metadata.json when set in the Deliverfile" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            meta = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileChangelog")
            expect(meta.deliver_process.deploy_information[:changelog]['en-US']).to eq("It works")
            expect(meta.deliver_process.deploy_information[:title]['en-US']).to eq("Overwritten")

            expect(meta.deliver_process.app.metadata.fetch_value("//x:title").first.content).to eq("Overwritten")
          end

          it "uses the fastlane environment ipa path if given for empty Deliverfiles" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            ipa_path = "./spec/fixtures/ipas/Example1.ipa"
            ENV["IPA_OUTPUT_PATH"] = ipa_path

            meta = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileIpaFromEnv")

            expect(ENV["DELIVER_IPA_PATH"]).to eq(ipa_path) # use this ipa

            ENV["IPA_OUTPUT_PATH"] = nil
          end

          it "Raises an exception when iTunes Transporter results in an error" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_ipa_error.txt")

            expect {
              Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacks")
            }.to raise_exception("Return status of iTunes Transporter was 1: ERROR ITMS-9000: \"Redundant Binary Upload. There already exists a binary upload with build '247' for version '1.13.0'\"".red)
          end

          it "Sets all the available metadata" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            meta = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMixed")

            expect(meta.deliver_process.app.app_identifier).to eq("net.sunapps.54")

            expect(meta.deliver_process.deploy_information[:changelog]).to eq({"en-US"=>"Thanks for using this app"})
            expect(meta.deliver_process.deploy_information[:version]).to eq("943.0")
            expect(meta.deliver_process.deploy_information[:description]).to eq({"en-US"=>"App description"})
            expect(meta.deliver_process.deploy_information[:privacy_url].values.first).to eq("http://privacy.sunapps.net")
            expect(meta.deliver_process.deploy_information[:marketing_url].values.first).to eq("http://www.sunapps.net")
            expect(meta.deliver_process.deploy_information[:support_url].values.first).to eq("http://support.sunapps.net")
            expect(meta.deliver_process.deploy_information[:title]).to eq({"en-US"=>"The ultimate iPhone app"})
            expect(meta.deliver_process.deploy_information[:keywords]).to eq({"en-US"=>["keyword1", "something", "else"]})
            expect(meta.deliver_process.deploy_information[:price_tier]).to eq(5)
          end

          it "Uses the given default language" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileDefaultLanguage")
            metadata = deliv.deliver_process.app.metadata

            expect(deliv.deliver_process.deploy_information[:keywords]['pt-BR']).to eq(["banese", "banco", "sergipe", "finanças"])

            expect(metadata.information['pt-BR'][:description][:value]).to eq("only description")
            expect(metadata.information['pt-BR'][:support_url][:value]).to eq("something")
            expect(metadata.information['pt-BR'][:version_whats_new][:value]).to eq("what's new?")
            # expect(metadata.information['pt-BR'][:keywords][:value]).to eq(["banese", "banco", "sergipe", "finanças"])
            expect(deliv.deliver_process.deploy_information[:changelog]['pt-BR']).to eq("what's new?")
          end

          it "Uploads all the available screenshots" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
            deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileScreenshots")
            screenshots = deliv.deliver_process.app.metadata.fetch_value("//x:software_screenshot")
            expect(screenshots.count).to eq(9)

            screenshots_path = "spec/fixtures/packages/#{deliv.deliver_process.app.apple_id}.itmsp/*.png"
            expect(Dir.glob(screenshots_path).count).to equal(screenshots.count)
            Dir.glob(screenshots_path) do |file|
              File.delete(file)
            end
          end

          it "Falls back to the default language if only one screenshot path is given" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileScreenshotsFallbackDefaultLanguage")
            expect(deliv.deliver_process.deploy_information[:screenshots_path]).to eq({"de-DE"=>"/tmp/notHere"})
          end

          it "Does not require an app version, when an ipa is given" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # the ipa file
            deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileNoVersion")

            expect(deliv.deliver_process.app.apple_id).to eq(464686641)
            expect(deliv.deliver_process.app.app_identifier).to eq('at.felixkrause.iTanky')
            expect(deliv.deliver_process.deploy_information.values.count).to eq(5)
          end

          it "Let's the user specify which languages should be supported" do
            Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

            deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileLocales")

            metadata = deliv.deliver_process.app.metadata
            expect(metadata.fetch_value("//x:locale").count).to eq(3)
            expect(metadata.fetch_value("//x:title").count).to eq(3)

            expect(metadata.information['de-DE'][:title][:value]).to eq("Deutscher Titel")
            expect(metadata.information['en-US'][:title][:value]).to eq("The ultimate iPhone app")
            expect(metadata.information['en-GB'][:title][:value]).to eq("The ultimate iPhone app") # default language

            expect(metadata.information['de-DE'][:version_whats_new][:value]).to eq("Deutscher Changelog")
            expect(metadata.information['en-US'][:version_whats_new][:value]).to eq("Thanks for using this app")
            expect(metadata.information['en-GB'][:version_whats_new][:value]).to eq("So british")
          end

          describe "#load_config_json_folder" do
            it "Correctly parses all the values for all the languages" do
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
              deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileMetadataJson")

              expect(deliv.deliver_process.deploy_information[:title].values.count).to eq(2) # languages
              expect(deliv.deliver_process.deploy_information[:title]['de-DE']).to eq("Mein App Titel")
              expect(deliv.deliver_process.deploy_information[:title]['en-US']).to eq("My App Title")
              expect(deliv.deliver_process.deploy_information[:description]['de-DE']).to eq("German Description")
              expect(deliv.deliver_process.deploy_information[:description]['en-US']).to eq("English Description here")
              expect(deliv.deliver_process.deploy_information[:keywords]['de-DE'].last).to eq("Tag1")
              expect(deliv.deliver_process.deploy_information[:keywords]['en-US'].last).to eq("Keyword1")
            end
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

              # Check the hash that should be stored
              error = JSON.parse(File.read(@success_path))
              expect(error['app_identifier']).to eq('at.felixkrause.iTanky')
              expect(error['app_version']).to eq('1.0')
              expect(error['error']).to eq(nil)
              expect(error['ipa_path']).to eq('./spec/fixtures/ipas/Example1.ipa')
              expect(error['is_beta_build']).to eq(false)
              expect(error['is_release_build']).to eq(true)
              expect(error['skipped_deploy']).to eq(false)
            end

            it "Successful with custom parameters" do
              expect(File.exists?@tests_path).to eq(false)
              Deliver::ItunesTransporter.clear_mock_files # we don't even download the app metadata
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # the ipa file
              deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacks",
                                force: true,
                                is_beta_ipa: true,
                                skip_deploy: true)
              expect(File.exists?@tests_path).to eq(true)
              expect(File.exists?@success_path).to eq(true)
              expect(File.exists?@error_path).to eq(false)

              # Check the hash that should be stored
              error = JSON.parse(File.read(@success_path))
              expect(error['app_identifier']).to eq('at.felixkrause.iTanky')
              expect(error['app_version']).to eq('1.0')
              expect(error['error']).to eq(nil)
              expect(error['ipa_path']).to eq('./spec/fixtures/ipas/Example1.ipa')
              expect(error['is_beta_build']).to eq(true)
              expect(error['is_release_build']).to eq(false)
              expect(error['skipped_deploy']).to eq(true)
            end

            it "Error on ipa upload" do
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_invalid.txt") # the ipa file
              expect {
                deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacks")
              }.to raise_exception
              expect(File.exists?@tests_path).to eq(true)
              expect(File.exists?@success_path).to eq(false)
              expect(File.exists?@error_path).to eq(true)

              # Check the hash that should be stored
              error = JSON.parse(File.read(@error_path))
              expect(error['app_identifier']).to eq('at.felixkrause.iTanky')
              expect(error['app_version']).to eq('1.0')
              expect(error['error']).to eq('Error uploading ipa file'.red)
              expect(error['ipa_path']).to eq('./spec/fixtures/ipas/Example1.ipa')
              expect(error['is_beta_build']).to eq(false)
              expect(error['is_release_build']).to eq(true)
              expect(error['skipped_deploy']).to eq(false)
            end

            it "Error on app metadata upload" do
              Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_invalid.txt")
              expect {
                deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacks")
              }.to raise_exception

              expect(File.exists?@tests_path).to eq(true)
              expect(File.exists?@success_path).to eq(false)
              expect(File.exists?@error_path).to eq(true)
            end

            it "Error on unit tests" do
              Deliver::ItunesTransporter.clear_mock_files # since we don't even download the metadata

              expect(File.exists?@tests_path).to eq(false)
              expect {
                deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacksFailingTests")
              }.to raise_exception
              expect(File.exists?@tests_path).to eq(true)
              expect(File.exists?@success_path).to eq(false)
              expect(File.exists?@error_path).to eq(true)
            end

            it "Error on unit tests with no error block raises an exception" do
              Deliver::ItunesTransporter.clear_mock_files # since we don't even download the metadata
              expect {
                deliv = Deliver::Deliverer.new("./spec/fixtures/Deliverfiles/DeliverfileCallbacksNoErrorBlock")
              }.to raise_exception("Unit tests failed. Got result: 'false'. Need 'true' or 1 to succeed.".red)
            end
          end
        end
      end
    end
  end
end
