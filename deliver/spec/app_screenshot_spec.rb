require 'deliver/app_screenshot'
require 'deliver/setup'

describe Deliver::AppScreenshot do
  before do
    allow(FastImage).to receive(:size).and_return([2732, 2048])
  end

  describe "should resolve iPad Pro (12.9-inch) ambiguity if" do
    it "has path not including distinction" do
      screenshot = Deliver::AppScreenshot.new("path/to/screenshot/Screen-Name-iPad Pro (12.9-inch).png", "de-DE")
      expect(screenshot.screen_size).to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_PRO)
    end

    it "has path including distinction" do
      screenshot = Deliver::AppScreenshot.new("path/to/screenshot/Screen-Name-iPad Pro (12.9-inch) (3rd generation).png", "de-DE")
      expect(screenshot.screen_size).to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_PRO129_3RD)
    end
  end
end
