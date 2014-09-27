describe IosDeployKit do
  describe IosDeployKit::MetadataItem do
    let (:path) { "./spec/metadata_item_spec.rb" }

    describe "#init" do
      it "raises an exception if file was not found" do
        other_path = "./notHere.png"
        expect {
          IosDeployKit::MetadataItem.new(other_path)
        }.to raise_error("File not found at path '#{other_path}'")
      end

      it "properly saves the path" do
        res = IosDeployKit::MetadataItem.new(path)
        res.path.should eq(path)
      end
    end

    describe "after init" do
      before do
        @item = IosDeployKit::MetadataItem.new(path)
        @doc = Nokogiri::XML(File.read("./spec/fixtures/example1.itmsp/metadata.xml"))
      end

      describe "#create_xml_node" do
        it "properly creates a valid nokogiri xml node" do
          node = @item.create_xml_node(@doc)
          node.children.first.content.should eq(File.size(path).to_s)
          node.children[1].content.should eq(path)
          node.children.last['type'].should eq("md5")
        end
      end
    end

  end
end