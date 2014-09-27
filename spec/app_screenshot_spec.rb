describe IosDeployKit do
  describe IosDeployKit::AppScreenshot do
    let (:path) { "./spec/app_screenshot_spec.rb" }

    describe "#init" do
      it "raises an exception if image file was not found" do
        path = "./notHere.png"
        expect {
          IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_35)
        }.to raise_error("File not found at path '#{path}'")
      end

      it "properly saves the path and screen size" do
        path = "./spec/app_screenshot_spec.rb"
        res = IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_35)
        res.path.should eq(path)
        res.screen_size.should eq(IosDeployKit::ScreenSize::IOS_35)
      end
    end

    describe "after init" do
      before do
        @item = IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_47)
        @doc = Nokogiri::XML(File.read("./spec/fixtures/example1.itmsp/metadata.xml"))
      end

      describe "#create_xml_node" do
        it "properly creates a valid nokogiri xml node for the screenshot" do
          order_index = 1
          node = @item.create_xml_node(@doc, order_index)
          node.children.first.content.should eq(File.size(path).to_s)
          node.children[1].content.should eq(path)
          node.children.last['type'].should eq("md5")

          node['position'].should eq(order_index.to_s)
          node['display_target'].should eq(IosDeployKit::ScreenSize::IOS_47)
        end
      end
    end

  end
end