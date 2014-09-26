describe IosDeployKit do
  describe IosDeployKit::AppScreenshot do

    it "raises an exception if image file was not found" do
      path = "./nonExistint.png"
      expect {
        IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_35)
      }.to raise_error("Screenshot not found at path '#{path}'")
    end
  end
end