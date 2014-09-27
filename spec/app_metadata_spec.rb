describe IosDeployKit do
  describe IosDeployKit::AppMetadata do
    let (:apple_id) { 794902327 }
    let (:app_identifier) { 'net.sunapps.1' }

    [
      "./spec/fixtures/example1.itmsp/",
      "./spec/fixtures/example2.itmsp/"
    ].each do |current_path|
      describe "Example metadata #{current_path.split('/').last}" do
        before do
          @app = IosDeployKit::App.new(apple_id, app_identifier)

          @app.metadata = IosDeployKit::AppMetadata.new(@app, current_path, false)

          @number_of_screenshots = (current_path.include?("example1") ? 8 : 0)
        end

        it "properly cleaned up the live version, which cannot be updated" do
          @app.metadata.fetch_value("//x:version").count.should eq(1)
          @app.metadata.fetch_value("//x:version").first['string'].should eq("0.9.10")
        end

        describe "#update_title" do

          it "updates the title" do
            new_title = "So new title"

            @app.metadata.fetch_value("//x:title").first.content.should eq('Example App Title')
            @app.metadata.update_title({ 'de-DE' => new_title })

            @app.metadata.fetch_value("//x:title").first.content.should eq(new_title)
          end

          it "supports the & symbol properly" do
            new_title = "something & something else"
            @app.metadata.update_title({ 'de-DE' => new_title })

            @app.metadata.fetch_value("//x:title").first.content.should eq(new_title)
          end
        end

        describe "#update_description" do

          it "throws an exception when a string is given instead of a hash" do
            expect {
              @app.metadata.update_description("something")
            }.to raise_error("Please pass a hash of languages to this method")
          end

          it "updates the description when a hash is given" do
            description = "Something Deutsch"

            @app.metadata.update_description({
              'de-DE' => description
            })
            
            @app.metadata.fetch_value("//x:description").first.content.should eq(description)
          end
        end

        describe "#update_changelog" do
          it "updates the changelog" do
            new_value = "What's new?"
            @app.metadata.update_changelog({ 'de-DE' => new_value })
            @app.metadata.fetch_value("//x:version_whats_new").first.content.should eq(new_value)
          end
        end

        describe "#update_marketing_url" do
          it "updates the marketing URL" do
            new_value = "http://google.com"
            @app.metadata.fetch_value("//x:software_url").first.content.should eq('http://sunapps.net')
            @app.metadata.update_marketing_url({ 'de-DE' => new_value })
            @app.metadata.fetch_value("//x:software_url").first.content.should eq(new_value)
          end
        end

        describe "#update_support_url" do
          it "updates the support URL" do
            new_value = "http://krause.pizza"
            @app.metadata.fetch_value("//x:support_url").first.content.should eq('http://www.sunapps.net/')
            @app.metadata.update_support_url({ 'de-DE' => new_value })
            @app.metadata.fetch_value("//x:support_url").first.content.should eq(new_value)
          end
        end


        describe "#update_keywords" do
          it "throws an exception when a string is given instead of an array" do
            expect {
              @app.metadata.update_keywords({ "de-DE" => "keyword1, keyword2" })
            }.to raise_error("Parameter needs to be a hash (each language) with an array of keywords in it")
          end

          it "updates the keywords when a hash of arrays is given" do
            tags = ["SunApps", "Felix", "Krause"]

            @app.metadata.fetch_value("//x:keyword")

            @app.metadata.update_keywords({
              'de-DE' => tags
            })
            
            result = @app.metadata.fetch_value("//x:keyword")
            result.count.should eq(tags.count)
            result[0].content.should eq(tags[0])
            result[1].content.should eq(tags[1])
            result[2].content.should eq(tags[2])
          end
        end

        describe "#clear_all_screenshots" do
          it "clears all the screenshots of the given language" do
            @app.metadata.fetch_value("//x:software_screenshot").count.should eq(@number_of_screenshots)
            @app.metadata.clear_all_screenshots("de-DE")
            @app.metadata.fetch_value("//x:software_screenshot").count.should eq(0)
          end
        end

        describe "#set_all_screenshots" do
          let (:error_message) { "Please pass a hash, containing an array of AppScreenshot objects" }
          it "raises an error when not passing a hash" do
            expect {
              @app.metadata.set_all_screenshots([])
            }.to raise_error(error_message)
          end

          it "raises an error when passing empty arrays" do
            expect {
              @app.metadata.set_all_screenshots({ 'de-DE' => [] })
            }.to raise_error(error_message)
          end

          it "raises an error when not using AppScreenshot objects" do
            expect {
              @app.metadata.set_all_screenshots({ 'de-DE' => ["./screenshot.png"] })
            }.to raise_error(error_message)
          end

          it "properly updates the metadata information when providing correct inputs", now: true do
            path = './spec/fixtures/screenshot1.png'

            @app.metadata.fetch_value("//x:software_screenshot").count.should eq(@number_of_screenshots)
            @app.metadata.set_all_screenshots({
              'de-DE' => [
                IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_35),
                IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_35),
                IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_35)
              ]
            })
            results = @app.metadata.fetch_value("//x:software_screenshot")
            results.count.should eq(3)
            results[0]['position'].should eq('1')
            results[1]['position'].should eq('2')
            results[2]['position'].should eq('3')
          end
        end

        describe "#add_screenshot", now: true do
          it "allows the user to add multiple screenshots" do
            @app.apple_id = 878567776
            @app.metadata.clear_all_screenshots('de-DE')
            @app.metadata.clear_all_screenshots('en-US')
            @app.metadata.fetch_value("//x:software_screenshot").count.should eq(0)

            # The order is quite important. en-US first, since we check using the index afterwards
            @app.metadata.add_screenshot('en-US', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_47))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_55))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_55))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_47))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_55))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_IPAD))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_IPAD))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_IPAD))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_IPAD))
            @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_IPAD))

            expect {
              @app.metadata.add_screenshot('de-DE', IosDeployKit::AppScreenshot.new('/Users/felixkrause/Desktop/screen.png', IosDeployKit::ScreenSize::IOS_IPAD))
            }.to raise_error("Only 5 screenshots are allowed per language per device type (iOS-iPad)")
            
            
            results = @app.metadata.fetch_value("//x:software_screenshot")
            results.count.should eq(10)

            results[0]['position'].should eq('1')
            results[1]['position'].should eq('1')
            results[2]['position'].should eq('2')
            results[3]['position'].should eq('1')
            results[4]['position'].should eq('3')
            results[5]['position'].should eq('1')
            results[6]['position'].should eq('2')
            results[7]['position'].should eq('3')
            results[8]['position'].should eq('4')
            results[9]['position'].should eq('5')
          end
        end
      end
    end
  end
end