describe Deliver do
  describe Deliver::ItunesConnect do
    describe "#update_app_icon" do
      it "raises an error when image resolution is wrong" do
        app = Deliver::App.new(apple_id: 912330783, app_identifier: 'net.sunapps.54')
        expect {
          app.upload_app_icon!('./spec/fixtures/screenshots/iPhone4.png')
        }.to raise_error "App icon must have the resolution of 1024x1024px".red
      end
    end
  end
end