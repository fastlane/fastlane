describe IosDeployKit do
  describe IosDeployKit::AppMetadata do
    let (:apple_id) { 794902327 }
    let (:app_identifier) { 'net.sunapps.1' }

    before do
      @app = IosDeployKit::App.new(apple_id, app_identifier)

      @app.metadata = IosDeployKit::AppMetadata.new(@app, "./spec/fixtures/example1.itmsp/", false)
    end

    it "properly cleaned up the live version, which cannot be updated" do
      @app.metadata.fetch_value("//x:version").count.should eq(1)
      @app.metadata.fetch_value("//x:version").first.attr('string').should eq("0.9.10")
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

    describe "#clear_all_screenshots", now: true do
      it "clears all the screenshots of the given language" do
        @app.metadata.fetch_value("//x:software_screenshot").count.should eq(8)
        @app.metadata.clear_all_screenshots("de-DE")
        @app.metadata.fetch_value("//x:software_screenshot").count.should eq(0)
      end
    end
  end
end