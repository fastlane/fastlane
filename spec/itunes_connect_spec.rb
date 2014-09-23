describe IosDeployKit do
  describe IosDeployKit::ItunesConnect do
    it "works" do
      app = IosDeployKit::App.new
      app.apple_id = "904332168"
      app.app_identifier = "net.sunapps.54"

      app.open_in_itunes_connect
      app.create_new_version("0.9.11")
    end
  end
end