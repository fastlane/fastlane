describe IosDeployKit do
  describe IosDeployKit::AppMetadata do
    let (:apple_id) { 794902327 }
    let (:app_identifier) { 'net.sunapps.1' }

    describe "#update_description" do
      before do
        @app = IosDeployKit::App.new(apple_id, app_identifier)
      end

      it "throws an exception when a string is given instead of a string" do
        expect {
          @app.metadata.update_description("something")
        }.to raise_error("Please pass a hash of languages to this method")
      end

      it "updates the description when a hash is given", now: true do
        @app.metadata.update_description({
          'de' => "new"
        })
        # TODO
        # @app.upload_metadata!
      end
    end
  end
end