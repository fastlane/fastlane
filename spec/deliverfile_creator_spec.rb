describe Deliver do
  describe Deliver::DeliverfileCreator do
    before do
      @path = "/tmp"
      @deliver_path = [@path, 'Deliverfile'].join("/")
      
      FileUtils.rm(@deliver_path) rescue nil
    end

    it "can create an example Deliverfile" do
      Deliver::DeliverfileCreator.create_example_deliver_file(@deliver_path, 'deliver')
      expect(File.read(@deliver_path)).to include("Dynamic generation of the ipa file")

      default = File.read("./lib/assets/DeliverfileExample")
      default.gsub!("[[APP_NAME]]", "deliver") # default name
      expect(File.read(@deliver_path)).to eq(default)
    end

    it "raises an error if Deliverfile already exists" do
      Deliver::DeliverfileCreator.create_example_deliver_file(@deliver_path, 'deliver')
      expect {
        Deliver::DeliverfileCreator.create(@path)
      }.to raise_error("Deliverfile already exists at path '/tmp/Deliverfile'. Run 'deliver' to use Deliver.".red)
    end

    it "Can create a Deliverfile based on an existing app" do
      identifier = 'net.sunapps.54'
      apple_id = 284882215

      deliver_path = "/tmp/deliver/"
      FileUtils.rm_rf(deliver_path) rescue nil
      FileUtils.rm_rf("/tmp/#{apple_id}.itmsp") rescue nil



      Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")

      folder = "/tmp/#{apple_id}.itmsp"
      system("cp -R './spec/fixtures/example1.itmsp/' '#{folder}'")

      project_name = "somethingFancy"
      Deliver::DeliverfileCreator.create_based_on_identifier(@path, identifier, project_name)

      
      
      # Check if all the files were correctly created at /tmp

      # Check metadata.json
      metadata = JSON.parse(File.read("#{deliver_path}/metadata.json"))
      expect(metadata['en-US']['title']).to eq('Default English Title')
      expect(metadata['de-DE']['title']).to eq('Example App Title')
      expect(metadata['de-DE']['description']).to include('3D GPS Birdiebuch')
      expect(metadata['de-DE']['version_whats_new']).to include('- Changelog Line 1')
      expect(metadata['de-DE']['software_url']).to eq('http://sunapps.net')
      expect(metadata['de-DE']['support_url']).to eq('http://www.sunapps.net/')
      expect(metadata['de-DE']['keywords']).to eq(%w|personal sunapps sun sunapps felix krause|)

      # Check Deliverfile
      correct = File.read("./lib/assets/DeliverfileDefault")
      correct.gsub!("[[APP_IDENTIFIER]]", 'net.sunapps.54')
      correct.gsub!("[[APP_NAME]]", project_name)
      correct.gsub!("[[EMAIL]]", ENV["DELIVER_USER"])
      expect(File.read("/tmp/Deliverfile")).to eq(correct)

      expect(File.directory?([deliver_path, "screenshots"].join("/"))).to eq(true)
      expect(File.directory?([deliver_path, "screenshots", "de-DE"].join("/"))).to eq(true)
      expect(File.directory?([deliver_path, "screenshots", "en-US"].join("/"))).to eq(true)
      expect(File.directory?([deliver_path, "screenshots", "en-AU"].join("/"))).to eq(false)

      expect(File.read("/tmp/deliver/screenshots/README.txt")).to eq(File.read("./lib/assets/ScreenshotsHelp"))
    end
  end
end