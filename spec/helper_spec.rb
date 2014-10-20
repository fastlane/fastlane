describe Deliver do
  describe Deliver::Helper do

    if OS.mac?
      it "#xcode_path" do
        expect(Deliver::Helper.xcode_path[-1]).to eq('/')
        expect(Deliver::Helper.xcode_path).to eq("/Applications/Xcode.app/Contents/Developer/")
      end

      it "#transporter_path" do
        expect(Deliver::Helper.transporter_path).to eq("/Applications/Xcode.app/Contents/Developer/../Applications/Application\\ Loader.app/Contents/MacOS/itms/bin/iTMSTransporter")
      end
    end
    
  end
end