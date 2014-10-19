describe Deliver do
  describe Deliver::AppScreenshot do
    let (:path) { "./spec/fixtures/screenshots/screenshot1.png" }

    describe "#init" do
      it "raises an exception if image file was not found" do
        path = "./notHere.png"
        expect {
          Deliver::AppScreenshot.new(path, Deliver::ScreenSize::IOS_40)
        }.to raise_error("File not found at path '#{path}'")
      end

      it "properly saves the path and screen size" do
        path = "./spec/app_screenshot_spec.rb"
        res = Deliver::AppScreenshot.new(path, Deliver::ScreenSize::IOS_40)
        expect(res.path).to eq(path)
        expect(res.screen_size).to eq(Deliver::ScreenSize::IOS_40)
      end
    end

    describe "after init" do
      before do
        @item = Deliver::AppScreenshot.new(path, Deliver::ScreenSize::IOS_40)
        @doc = Nokogiri::XML(File.read("./spec/fixtures/example1.itmsp/metadata.xml"))
      end

      describe "#create_xml_node" do
        it "properly creates a valid nokogiri xml node for the screenshot" do
          order_index = 1
          node = @item.create_xml_node(@doc, order_index)
          expect(node.children.first.content).to eq(File.size(path).to_s)
          expect(node.children[1].content).to eq("30fbc3071dc36b824bcd5960bcfef775.png")
          expect(node.children.last['type']).to eq("md5")
          expect(node.children.last.content).to eq("e2c116d8f1ab7982a2b131ac681b6e86")

          expect(node['position']).to eq(order_index.to_s)
          expect(node['display_target']).to eq(Deliver::ScreenSize::IOS_40)
        end
      end

      describe "#is_valid?" do
        it "is not valid when it's not a png" do
          expect(@item.is_valid?).to eq(true)

          @item.path = "./something.jpg"
          expect(@item.is_valid?).to eq(false)
        end

        it "it is not valid, when the size does not match the given type" do
          expect(@item.is_valid?).to eq(true)

          @item.screen_size = Deliver::ScreenSize::IOS_55
          expect(@item.is_valid?).to eq(false) # wrong size
        end
      end

      describe "#calculate_screen_size" do
        it "it will return the size for a given png file" do
          p = "./spec/fixtures/screenshots/de-DE/"

          files = [
            ['iPhone4.png', 'iOS-3.5-in'],
            ['iPhone6.png', 'iOS-4.7-in'],
            ['iPhone6Plus1.png', 'iOS-5.5-in'],
            ['iPhone6Plus2.png', 'iOS-5.5-in'],
            ['screenshot1.png', 'iOS-4-in']
          ]

          files.each do |value|
            expect(Deliver::AppScreenshot.calculate_screen_size(p + value[0])).to eq(value[1])
          end
        end
      end
    end

  end
end