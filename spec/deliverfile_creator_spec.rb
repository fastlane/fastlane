describe Deliver do
  describe Deliver::DeliverfileCreator do
    it "can create an example Deliverfile" do
      path = "/tmp/Deliverfile"
      
      FileUtils.rm(path) rescue nil
      
      Deliver::DeliverfileCreator.create_example_deliver_file(path)
      expect(File.read(path)).to include("Dynamic generation of the ipa file")

      default = File.read("./lib/assets/DeliverfileExample")
      default.gsub!("[[APP_NAME]]", "deliver") # default name
      expect(File.read(path)).to eq(default)
    end
  end
end