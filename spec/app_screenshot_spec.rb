describe IosDeployKit do
  describe IosDeployKit::AppScreenshot, now: true do
    let (:path) { "./spec/fixtures/screenshot1.png" }

    describe "#init" do
      it "raises an exception if image file was not found" do
        path = "./notHere.png"
        expect {
          IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_40)
        }.to raise_error("File not found at path '#{path}'")
      end

      it "properly saves the path and screen size" do
        path = "./spec/app_screenshot_spec.rb"
        res = IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_40)
        res.path.should eq(path)
        res.screen_size.should eq(IosDeployKit::ScreenSize::IOS_40)
      end
    end

    describe "after init" do
      before do
        @item = IosDeployKit::AppScreenshot.new(path, IosDeployKit::ScreenSize::IOS_40)
        @doc = Nokogiri::XML(File.read("./spec/fixtures/example1.itmsp/metadata.xml"))
      end

      describe "#create_xml_node" do
        it "properly creates a valid nokogiri xml node for the screenshot" do
          order_index = 1
          node = @item.create_xml_node(@doc, order_index)
          node.children.first.content.should eq(File.size(path).to_s)
          node.children[1].content.should eq("screenshot1.png")
          node.children.last['type'].should eq("md5")
          node.children.last.content.should eq("be2b3268bdd8fef0f9426629918adf9a")

          node['position'].should eq(order_index.to_s)
          node['display_target'].should eq(IosDeployKit::ScreenSize::IOS_40)
        end
      end

      describe "is_valid?" do
        it "is not valid when it's not a png" do
          @item.is_valid?.should eq(true)

          @item.path = "./something.jpg"
          @item.is_valid?.should eq(false)
        end

        it "it is not valid, when the size does not match the given type" do
          @item.is_valid?.should eq(true)

          @item.screen_size = IosDeployKit::ScreenSize::IOS_55
          @item.is_valid?.should eq(false) # wrong size
        end
      end
    end

  end
end