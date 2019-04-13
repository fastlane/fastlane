require 'deliver/app_screenshot'
require 'deliver/setup'

describe Deliver::AppScreenshot do
  before do
    allow(FastImage).to receive(:size).and_return([2732, 2048])
  end

  describe "#initialize" do
    context "when filename doesn't contain '(3rd generation)'" do
      it "returns iPad Pro(12.9-inch)" do
        screenshot = Deliver::AppScreenshot.new("path/to/screenshot/Screen-Name-iPad Pro (12.9-inch).png", "de-DE")
        expect(screenshot.screen_size).to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_PRO)
      end
    end

    context "when filename contains '(3rd generation)" do
      it "returns iPad Pro(12.9-inch) 3rd generation" do
        screenshot = Deliver::AppScreenshot.new("path/to/screenshot/Screen-Name-iPad Pro (12.9-inch) (3rd generation).png", "de-DE")
        expect(screenshot.screen_size).to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_PRO_12_9)
      end
    end
  end
end
