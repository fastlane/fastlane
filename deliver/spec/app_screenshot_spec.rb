require 'deliver/app_screenshot'
require 'deliver/setup'

describe Deliver::AppScreenshot do

  def screen_size_from(path)
    path.match(/{([0-9]+)x([0-9]+)}/).captures.map(&:to_i)
  end

  before do
    allow(FastImage).to receive(:size) do |path|
      screen_size_from(path)
    end
  end

  describe "#initialize" do
    context "when filename doesn't contain 'iPad Pro (3rd generation)' or 'iPad Pro (4th generation)'" do
      it "returns iPad Pro(12.9-inch)" do
        screenshot = Deliver::AppScreenshot.new("path/to/screenshot/Screen-Name-iPad Pro (12.9-inch){2732x2048}.png", "de-DE")
        expect(screenshot.display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_129)
      end
    end

    context "when filename contains 'iPad Pro (3rd generation)'" do
      it "returns iPad Pro(12.9-inch) 3rd generation" do
        screenshot = Deliver::AppScreenshot.new("path/to/screenshot/Screen-Name-iPad Pro (12.9-inch) (3rd generation){2732x2048}.png", "de-DE")
        expect(screenshot.display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_129)
      end
    end

    context "when filename contains 'iPad Pro (4th generation)'" do
      it "returns iPad Pro(12.9-inch) 3rd generation" do
        screenshot = Deliver::AppScreenshot.new("path/to/screenshot/Screen-Name-iPad Pro (12.9-inch) (4th generation){2732x2048}.png", "de-DE")
        expect(screenshot.display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_129)
      end
    end

    context "when filename contains 'iPad Pro (5th generation)'" do
      it "returns iPad Pro(12.9-inch) 3rd generation" do
        screenshot = Deliver::AppScreenshot.new("path/to/screenshot/Screen-Name-iPad Pro (12.9-inch) (5th generation){2732x2048}.png", "de-DE")
        expect(screenshot.display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_129)
      end
    end

    context "when filename contains 'IPAD_PRO_3GEN_129'" do
      it "returns iPad Pro(12.9-inch) 3rd generation" do
        screenshot = Deliver::AppScreenshot.new("path/to/screenshot/IPAD_PRO_3GEN_129-AAABBBCCCDDD{2732x2048}.png", "de-DE")
        expect(screenshot.display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_129)
      end
    end

    context "when filename contains 'ipadPro129'" do
      it "returns iPad Pro(12.9-inch) 3rd generation" do
        screenshot = Deliver::AppScreenshot.new("path/to/screenshot/ipadPro129-AAABBBCCCDDD{2732x2048}.png", "de-DE")
        expect(screenshot.display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_129)
      end
    end
  end

  # Ensure that screenshots correctly map based on the following:
  # https://help.apple.com/app-store-connect/#/devd274dd925
  describe "#calculate_display_type" do
    def expect_display_type_from_file(file)
      expect(Deliver::AppScreenshot.calculate_display_type(file))
    end

    describe "valid screen sizes" do
      it "should calculate all 6.7 inch iPhone resolutions" do
        expect_display_type_from_file("iPhone14ProMax-Portrait{1260x2736}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_67)
        expect_display_type_from_file("iPhone14ProMax-Landscape{2736x1260}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_67)
        expect_display_type_from_file("iPhone14ProMax-Portrait{1290x2796}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_67)
        expect_display_type_from_file("iPhone14ProMax-Landscape{2796x1290}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_67)
        expect_display_type_from_file("iPhone16ProMax-Portrait{1320x2868}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_67)
        expect_display_type_from_file("iPhone16ProMax-Landscape{2868x1320}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_67)
      end

      it "should calculate all 6.5 inch iPhone resolutions" do
        expect_display_type_from_file("iPhoneXSMax-Portrait{1242x2688}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_65)
        expect_display_type_from_file("iPhoneXSMax-Landscape{2688x1242}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_65)
        expect_display_type_from_file("iPhone12ProMax-Portrait{1284x2778}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_65)
        expect_display_type_from_file("iPhone12ProMax-Landscape{2778x1284}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_65)
      end

      it "should calculate all 6.1 inch iPhone resolutions" do
        expect_display_type_from_file("iPhone14Pro-Portrait{1179x2556}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_61)
        expect_display_type_from_file("iPhone14Pro-Landscape{2556x1179}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_61)
        expect_display_type_from_file("iPhone15Pro-Portrait{1206x2622}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_61)
        expect_display_type_from_file("iPhone15Pro-Landscape{2622x1206}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_61)
      end

      it "should calculate all 5.8 inch iPhone resolutions" do
        expect_display_type_from_file("iPhone12-Portrait{1170x2532}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_58)
        expect_display_type_from_file("iPhone12-Landscape{2532x1170}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_58)
        expect_display_type_from_file("iPhoneXS-Portrait{1125x2436}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_58)
        expect_display_type_from_file("iPhoneXS-Landscape{2436x1125}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_58)
        expect_display_type_from_file("iPhoneX-Portrait{1080x2340}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_58)
        expect_display_type_from_file("iPhoneX-Landscape{2340x1080}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_58)
      end

      it "should calculate all 5.5 inch iPhone resolutions" do
        expect_display_type_from_file("iPhone8Plus-Portrait{1242x2208}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_55)
        expect_display_type_from_file("iPhone8Plus-Landscape{2208x1242}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_55)
      end

      it "should calculate all 4.7 inch iPhone resolutions" do
        expect_display_type_from_file("iPhone8-Portrait{750x1334}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_47)
        expect_display_type_from_file("iPhone8-Landscape{1334x750}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_47)
      end

      it "should calculate all 4 inch iPhone resolutions" do
        expect_display_type_from_file("iPhoneSE-Portrait{640x1136}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_40)
        expect_display_type_from_file("iPhoneSE-Landscape{1136x640}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_40)
        expect_display_type_from_file("iPhoneSE-Portrait-NoStatusBar{640x1096}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_40)
        expect_display_type_from_file("iPhoneSE-Landscape-NoStatusBar{1136x600}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_40)
      end

      it "should calculate all 3.5 inch iPhone resolutions" do
        expect_display_type_from_file("iPhone4S-Portrait{640x960}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_35)
        expect_display_type_from_file("iPhone4S-Landscape{960x640}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_35)
        expect_display_type_from_file("iPhone4S-Portrait-NoStatusBar{640x920}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_35)
        expect_display_type_from_file("iPhone4S-Landscape-NoStatusBar{960x600}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_35)
      end

      it "should calculate all 12.9 inch iPad resolutions" do
        expect_display_type_from_file("iPad-Portrait-12_9Inch{2048x2732}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_129)
        expect_display_type_from_file("iPad-Landscape-12_9Inch{2732x2048}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_129)
      end

      it "should calculate all 11 inch iPad resolutions" do
        expect_display_type_from_file("iPad-Portrait-11Inch{1488x2266}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
        expect_display_type_from_file("iPad-Landscape-11Inch{2266x1488}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
        expect_display_type_from_file("iPad-Portrait-11Inch{1668x2420}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
        expect_display_type_from_file("iPad-Landscape-11Inch{2420x1668}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
        expect_display_type_from_file("iPad-Portrait-11Inch{1668x2388}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
        expect_display_type_from_file("iPad-Landscape-11Inch{2388x1668}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
        expect_display_type_from_file("iPad-Portrait-11Inch{1640x2360}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
        expect_display_type_from_file("iPad-Landscape-11Inch{2360x1640}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
      end

      it "should calculate all 10.5 inch iPad resolutions" do
        expect_display_type_from_file("iPad-Portrait-10_5Inch{1668x2224}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_105)
        expect_display_type_from_file("iPad-Landscape-10_5Inch{2224x1668}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_105)
      end

      it "should calculate all 9.7 inch iPad resolutions" do
        expect_display_type_from_file("iPad-Portrait-9_7Inch-Retina{1536x2048}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
        expect_display_type_from_file("iPad-Landscape-9_7Inch-Retina{2048x1536}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
        expect_display_type_from_file("iPad-Portrait-9_7Inch-Retina-NoStatusBar{1536x2008}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
        expect_display_type_from_file("iPad-Landscape-9_7Inch-Retina-NoStatusBar{2048x1496}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
        expect_display_type_from_file("iPad-Portrait-9_7Inch-{768x1024}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
        expect_display_type_from_file("iPad-Landscape-9_7Inch-{1024x768}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
        expect_display_type_from_file("iPad-Portrait-9_7Inch-NoStatusBar{768x1004}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
        expect_display_type_from_file("iPad-Landscape-9_7Inch-NoStatusBar{1024x748}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
      end

      it "should calculate all supported Mac resolutions" do
        expect_display_type_from_file("Mac{1280x800}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_DESKTOP)
        expect_display_type_from_file("Mac{1440x900}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_DESKTOP)
        expect_display_type_from_file("Mac{2560x1600}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_DESKTOP)
        expect_display_type_from_file("Mac{2880x1800}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_DESKTOP)
      end

      it "should calculate all supported Apple TV resolutions" do
        expect_display_type_from_file("AppleTV{1920x1080}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_APPLE_TV)
        expect_display_type_from_file("AppleTV-4K{3840x2160}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_APPLE_TV)
      end

      it "should calculate all supported Apple Watch resolutions" do
        expect_display_type_from_file("AppleWatch-Series3{312x390}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_3)
        expect_display_type_from_file("AppleWatch-Series4{368x448}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_4)
        expect_display_type_from_file("AppleWatch-Series7{396x484}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_7)
        expect_display_type_from_file("AppleWatch-Ultra{410x502}.jpg").to eq(Deliver::AppScreenshot::DisplayType::APP_WATCH_ULTRA)
      end
    end

    describe "valid iMessage app display types" do
      it "should calculate all 6.7 inch iPhone resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPhone14ProMax-Portrait{1290x2796}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_67)
        expect_display_type_from_file("iMessage/en-GB/iPhone14ProMax-Landscape{2796x1290}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_67)
      end

      it "should calculate all 6.5 inch iPhone resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPhoneXSMax-Portrait{1242x2688}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_65)
        expect_display_type_from_file("iMessage/en-GB/iPhoneXSMax-Landscape{2688x1242}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_65)
        expect_display_type_from_file("iMessage/en-GB/iPhone12ProMax-Portrait{1284x2778}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_65)
        expect_display_type_from_file("iMessage/en-GB/iPhone12ProMax-Landscape{2778x1284}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_65)
      end

      it "should calculate all 6.1 inch iPhone resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPhone14Pro-Portrait{1179x2556}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_61)
        expect_display_type_from_file("iMessage/en-GB/iPhone14Pro-Landscape{2556x1179}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_61)
      end

      it "should calculate all 5.8 inch iPhone resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPhoneXS-Portrait{1125x2436}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_58)
        expect_display_type_from_file("iMessage/en-GB/iPhoneXS-Landscape{2436x1125}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_58)
      end

      it "should calculate all 5.5 inch iPhone resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPhone8Plus-Portrait{1242x2208}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_55)
        expect_display_type_from_file("iMessage/en-GB/iPhone8Plus-Landscape{2208x1242}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_55)
      end

      it "should calculate all 4.7 inch iPhone resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPhone8-Portrait{750x1334}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_47)
        expect_display_type_from_file("iMessage/en-GB/iPhone8-Landscape{1334x750}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_47)
      end

      it "should calculate all 4 inch iPhone resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPhoneSE-Portrait{640x1136}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_40)
        expect_display_type_from_file("iMessage/en-GB/iPhoneSE-Landscape{1136x640}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_40)
        expect_display_type_from_file("iMessage/en-GB/iPhoneSE-Portrait-NoStatusBar{640x1096}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_40)
        expect_display_type_from_file("iMessage/en-GB/iPhoneSE-Landscape-NoStatusBar{1136x600}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_40)
      end

      it "should calculate all 12.9 inch iPad resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPad-Portrait-12_9Inch{2048x2732}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_PRO_129)
        expect_display_type_from_file("iMessage/en-GB/iPad-Landscape-12_9Inch{2732x2048}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_PRO_129)
      end

      it "should calculate all 11 inch iPad resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPad-Portrait-11Inch{1668x2388}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_11)
        expect_display_type_from_file("iMessage/en-GB/iPad-Landscape-11Inch{2388x1668}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_11)
      end

      it "should calculate all 10.5 inch iPad resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPad-Portrait-10_5Inch{1668x2224}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_105)
        expect_display_type_from_file("iMessage/en-GB/iPad-Landscape-10_5Inch{2224x1668}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_105)
      end

      it "should calculate all 9.7 inch iPad resolutions" do
        expect_display_type_from_file("iMessage/en-GB/iPad-Portrait-9_7Inch-Retina{1536x2048}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
        expect_display_type_from_file("iMessage/en-GB/iPad-Landscape-9_7Inch-Retina{2048x1536}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
        expect_display_type_from_file("iMessage/en-GB/iPad-Portrait-9_7Inch-Retina-NoStatusBar{1536x2008}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
        expect_display_type_from_file("iMessage/en-GB/iPad-Landscape-9_7Inch-Retina-NoStatusBar{2048x1496}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
        expect_display_type_from_file("iMessage/en-GB/iPad-Portrait-9_7Inch-{768x1024}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
        expect_display_type_from_file("iMessage/en-GB/iPad-Landscape-9_7Inch-{1024x768}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
        expect_display_type_from_file("iMessage/en-GB/iPad-Portrait-9_7Inch-NoStatusBar{768x1004}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
        expect_display_type_from_file("iMessage/en-GB/iPad-Landscape-9_7Inch-NoStatusBar{1024x748}.jpg").to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
      end
    end

    describe "invalid display types" do
      def expect_invalid_display_type_from_file(file)
        expect(Deliver::AppScreenshot.calculate_display_type(file)).to be_nil
      end

      it "shouldn't allow native resolution 5.5 inch iPhone screenshots" do
        expect_invalid_display_type_from_file("iPhone8Plus-NativeResolution{1080x1920}.jpg")
        expect_invalid_display_type_from_file("iMessage/en-GB/iPhone8Plus-NativeResolution{1080x1920}.jpg")
      end

      it "shouldn't calculate portrait Apple TV resolutions" do
        expect_invalid_display_type_from_file("appleTV/en-GB/AppleTV-Portrait{1080x1920}.jpg")
        expect_invalid_display_type_from_file("appleTV/en-GB/AppleTV-Portrait{2160x3840}.jpg")
      end

      it "shouldn't calculate modern devices excluding status bars" do
        expect_invalid_display_type_from_file("iPhoneXSMax-Portrait-NoStatusBar{1242x2556}.jpg")
        expect_invalid_display_type_from_file("iPhoneXS-Portrait-NoStatusBar{1125x2304}.jpg")
        expect_invalid_display_type_from_file("iPhone8Plus-Portrait-NoStatusBar{1242x2148}.jpg")
        expect_invalid_display_type_from_file("iPhone8-Portrait-NoStatusBar{750x1294}.jpg")
        expect_invalid_display_type_from_file("iPad-Portrait-12_9Inch-NoStatusBar{2048x2692}.jpg")
        expect_invalid_display_type_from_file("iPad-Portrait-11Inch{1668x2348}.jpg")
        expect_invalid_display_type_from_file("iPad-Portrait-10_5Inch{1668x2184}.jpg")
      end

      it "shouldn't allow non 16:10 resolutions for Mac" do
        expect_invalid_display_type_from_file("Mac-Portrait{800x1280}.jpg")
        expect_invalid_display_type_from_file("Mac-Portrait{900x1440}.jpg")
        expect_invalid_display_type_from_file("Mac-Portrait{1600x2560}.jpg")
        expect_invalid_display_type_from_file("Mac-Portrait{1800x2880}.jpg")
      end
    end
  end

  describe "#is_messages?" do
    it "should return true when contained in the iMessage directory" do
      files = [
        "screenshots/iMessage/en-GB/iPhoneXSMax-Portrait{1242x2688}.png",
        "screenshots/iMessage/en-GB/iPhoneXS-Portrait{1125x2436}.png",
        "screenshots/iMessage/en-GB/iPhone8Plus-Landscape{2208x1242}.png",
        "screenshots/iMessage/en-GB/iPhone8-Landscape{1334x750}.png",
        "screenshots/iMessage/en-GB/iPhoneSE-Portrait-NoStatusBar{640x1096}.png",
        "screenshots/iMessage/en-GB/iPad-Portrait-12_9Inch{2048x2732}.png",
        "screenshots/iMessage/en-GB/iPad-Portrait-11Inch{1668x2388}.png",
        "screenshots/iMessage/en-GB/iPad-Landscape-10_5Inch{2224x1668}.png",
        "screenshots/iMessage/en-GB/iPad-Portrait-9_7Inch-NoStatusBar{768x1004}.png"
      ]
      files.each do |file|
        screenshot = Deliver::AppScreenshot.new(file, 'en-GB')
        expect({ file: file, result: screenshot.is_messages? }).to eq({ file: file, result: true })
      end
    end

    it "should return false when not contained in the iMessage directory" do
      files = [
        "screenshots/en-GB/iPhoneXSMax-Portrait{1242x2688}.png",
        "screenshots/en-GB/iPhoneXS-Portrait{1125x2436}.png",
        "screenshots/en-GB/iPhone8Plus-Landscape{2208x1242}.png",
        "screenshots/en-GB/iPhone8-Landscape{1334x750}.png",
        "screenshots/en-GB/iPhoneSE-Portrait-NoStatusBar{640x1096}.png",
        "screenshots/en-GB/iPad-Portrait-12_9Inch{2048x2732}.png",
        "screenshots/en-GB/iPad-Portrait-11Inch{1668x2388}.png",
        "screenshots/en-GB/iPad-Landscape-10_5Inch{2224x1668}.png",
        "screenshots/en-GB/iPad-Portrait-9_7Inch-NoStatusBar{768x1004}.png",
        "screenshots/en-GB/Mac{1440x900}.png",
        "screenshots/en-GB/AppleWatch-Series4{368x448}.png",
        "screenshots/appleTV/en-GB/AppleTV-4K{3840x2160}.png"
      ]
      files.each do |file|
        screenshot = Deliver::AppScreenshot.new(file, 'en-GB')
        expect({ file: file, result: screenshot.is_messages? }).to eq({ file: file, result: false })
      end
    end
  end

  describe "#display_type" do
    def app_screenshot_with(display_type, path = '', language = 'en-US')
      allow(Deliver::AppScreenshot).to receive(:calculate_display_type).and_return(display_type)
      Deliver::AppScreenshot.new(path, language)
    end

    it "should return APP_IPHONE_35 for 3.5 inch displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPHONE_35).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_35)
    end

    it "should return appropriate display types for 4 inch displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPHONE_40).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_40)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_40).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_40)
    end

    it "should return appropriate display types for 4.7 inch displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPHONE_47).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_47)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_47).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_47)
    end

    it "should return appropriate display types for 5.5 inch displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPHONE_55).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_55)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_55).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_55)
    end

    it "should return appropriate display types for 6.1 inch displays (iPhone 14)" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPHONE_61).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_61)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_61).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_61)
    end

    it "should return appropriate display types for 6.7 inch displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPHONE_67).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_67)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_67).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_67)
    end

    it "should return appropriate display types for 6.5 inch displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPHONE_65).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_65)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_65).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPHONE_65)
    end

    it "should return appropriate display types for 9.7 inch iPad displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPAD_97).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_97)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_97)
    end

    it "should return appropriate display types for 10.5 inch iPad displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPAD_105).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_105)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_105).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_105)
    end

    it "should return appropriate display types for 11 inch iPad displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_3GEN_11)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_11).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_11)
    end

    it "should return appropriate display types for 12.9 inch iPad displays" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_129).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPAD_PRO_129)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_PRO_129).display_type).to eq(Deliver::AppScreenshot::DisplayType::IMESSAGE_APP_IPAD_PRO_129)
    end

    it "should return watch display types" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_3).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_3)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_4).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_4)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_7).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_7)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_WATCH_ULTRA).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_WATCH_ULTRA)
    end

    it "should return other device display types" do
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_APPLE_TV).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_APPLE_TV)
      expect(app_screenshot_with(Deliver::AppScreenshot::DisplayType::APP_DESKTOP).display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_DESKTOP)
    end
  end
end
