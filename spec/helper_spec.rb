describe IosDeployKit do
  describe IosDeployKit::Helper do

    if OS.mac?
      it "#xcode_path" do
        IosDeployKit::Helper.xcode_path[-1].should eq('/')
        IosDeployKit::Helper.xcode_path.should eq("/Applications/Xcode.app/Contents/Developer/")
      end

      it "#transporter_path" do
        IosDeployKit::Helper.transporter_path.should eq("/Applications/Xcode.app/Contents/Developer/../Applications/Application\\ Loader.app/Contents/MacOS/itms/bin/iTMSTransporter")
      end
    end
    
  end
end