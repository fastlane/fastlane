require 'deliver/upload_screenshots'
require 'fakefs/spec_helpers'

describe Deliver::UploadScreenshots do
  describe "#collect_screenshots_for_languages (screenshot collection)" do
    include(FakeFS::SpecHelpers)

    def add_screenshot(file)
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') { |f| f << 'touch' }
    end

    def collect_screenshots_from_dir(dir)
      Deliver::UploadScreenshots.new.collect_screenshots_for_languages(dir, false)
    end

    before do
      FakeFS::FileSystem.clone(File.join(Spaceship::ROOT, "lib", "assets", "displayFamilies.json"))
      allow(FastImage).to receive(:size) do |path|
        path.match(/{([0-9]+)x([0-9]+)}/).captures.map(&:to_i)
      end
    end

    it "should not find any screenshots when the directory is empty" do
      screenshots = collect_screenshots_from_dir("/Screenshots")
      expect(screenshots.count).to eq(0)
    end

    it "should find screenshot when present in the directory" do
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.screen_size).to eq(Deliver::AppScreenshot::ScreenSize::IOS_47)
    end

    it "should not collect iPhone XR screenshots" do
      add_screenshot("/Screenshots/en-GB/iPhoneXR-01First{828x1792}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(0)
    end

    it "should find different languages" do
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}.jpg")
      add_screenshot("/Screenshots/fr-FR/iPhone8-01First{750x1334}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots")
      expect(screenshots.count).to eq(2)
      expect(screenshots.group_by(&:language).keys).to include("en-GB", "fr-FR")
    end

    it "should not collect regular screenshots if framed varieties exist" do
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}.jpg")
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}_framed.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.path).to eq("/Screenshots/en-GB/iPhone8-01First{750x1334}_framed.jpg")
    end

    it "should collect Apple Watch screenshots" do
      add_screenshot("/Screenshots/en-GB/AppleWatch-01First{368x448}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
    end

    it "should continue to collect Apple Watch screenshots even when framed iPhone screenshots exist" do
      add_screenshot("/Screenshots/en-GB/AppleWatch-01First{368x448}.jpg")
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}.jpg")
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}_framed.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(2)
      expect(screenshots.group_by(&:device_type).keys).to include("watchSeries4", "iphone6")
    end

    it "should support special appleTV directory" do
      add_screenshot("/Screenshots/appleTV/en-GB/01First{3840x2160}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.device_type).to eq("appleTV")
    end

    it "should detect iMessage screenshots based on the directory they are contained within" do
      add_screenshot("/Screenshots/iMessage/en-GB/iPhone8-01First{750x1334}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.is_messages?).to be_truthy
    end

    it "should raise an error if unsupported screenshot sizes are in iMessage directory" do
      add_screenshot("/Screenshots/iMessage/en-GB/AppleTV-01First{3840x2160}.jpg")
      expect do
        collect_screenshots_from_dir("/Screenshots/")
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Unsupported screen size [3840, 2160] for path '/Screenshots/iMessage/en-GB/AppleTV-01First{3840x2160}.jpg'")
    end
  end
end
