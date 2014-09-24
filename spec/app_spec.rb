describe IosDeployKit do
  describe IosDeployKit::App do
    let (:apple_id) { 284882215 }
    let (:app_identifier) { 'com.facebook.Facebook' }
    describe "#initialize" do
      it "automatically fetches the app identifier, if only Apple ID is given" do
        app = IosDeployKit::App.new(apple_id)

        app.app_identifier.should eq(app_identifier)
        app.apple_id.should eq(apple_id)
      end

      it "lets me create an app using an Apple ID and app identifier" do
        app = IosDeployKit::App.new(apple_id, "com.facebook.Facebook")

        app.app_identifier.should eq(app_identifier)
        app.apple_id.should eq(apple_id)
      end

      it "lets me create an app without any information given (yet)" do
        IosDeployKit::App.new.app_identifier.should eq(nil)
      end
    end
  end
end