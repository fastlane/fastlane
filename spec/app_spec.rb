describe IosDeployKit do
  describe IosDeployKit::App do
    describe "#initialize" do
      it "automatically fetches the app identifier, if only Apple ID is given" do
        IosDeployKit::App.new(284882215).app_identifier.should eq('com.facebook.Facebook')
      end

      it "lets me create an app without any information given (yet)" do
        IosDeployKit::App.new.app_identifier.should eq(nil)
      end
    end
  end
end