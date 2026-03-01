require 'frameit/device'

describe Frameit::Device do
  def screen_size_from(path)
    path.match(/{([0-9]+)x([0-9]+)}/).captures.map(&:to_i)
  end

  before do
    allow(FastImage).to receive(:size) do |path|
      screen_size_from(path)
    end

    Frameit.config = instance_double("FastlaneCore::Configuration")
    allow(Frameit.config).to receive(:[]).with(anything).and_return(false)
  end

  Devices = Frameit::Devices
  Platform = Frameit::Platform

  # Ensure that devices are correctly detected based on resolutions, priorities and settings
  describe "#detect_device" do
    def expect_screen_size_from_file(file, platform)
      expect(Frameit::Device.detect_device(file, platform))
    end

    def expect_forced_screen_size(value)
      expect(Frameit::Device.find_device_by_id_or_name(value))
    end

    describe "valid iOS screen sizes" do
      it "should detect iPhone XS in portrait and landscape if filename contains \"Apple iPhone XS\"" do
        expect_screen_size_from_file("Apple iPhone XS-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_XS)
        expect_screen_size_from_file("Apple iPhone XS-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_XS)
      end

      it "should detect iPhone 14 in portrait and landscape based on priority" do
        expect_screen_size_from_file("screenshot-Portrait{1170x2532}.jpg", Platform::IOS).to eq(Devices::IPHONE_14)
        expect_screen_size_from_file("screenshot-Landscape{2532x1170}.jpg", Platform::IOS).to eq(Devices::IPHONE_14)
      end

      it "should detect iPhone 16 in portrait and landscape based on priority" do
        expect_screen_size_from_file("screenshot-Portrait{1179x2556}.jpg", Platform::IOS).to eq(Devices::IPHONE_16)
        expect_screen_size_from_file("screenshot-Landscape{2556x1179}.jpg", Platform::IOS).to eq(Devices::IPHONE_16)
      end

      it "should detect iPhone 16 Plus in portrait and landscape based on priority" do
        expect_screen_size_from_file("screenshot-Portrait{1290x2796}.jpg", Platform::IOS).to eq(Devices::IPHONE_16_PLUS)
        expect_screen_size_from_file("screenshot-Landscape{2796x1290}.jpg", Platform::IOS).to eq(Devices::IPHONE_16_PLUS)
      end

      it "should detect iPhone 16 Pro instead of iPhone 16 because of the file name containing device name" do
        expect_screen_size_from_file("Apple iPhone 16 Pro-Portrait{1206x2622}.jpg", Platform::IOS).to eq(Devices::IPHONE_16_PRO)
        expect_screen_size_from_file("Apple iPhone 16 Pro-Landscape{2622x1206}.jpg", Platform::IOS).to eq(Devices::IPHONE_16_PRO)
      end

      it "should detect iPhone 17 Pro in portrait and landscape based on priority" do
        expect_screen_size_from_file("screenshot-Portrait{1206x2622}.jpg", Platform::IOS).to eq(Devices::IPHONE_17_PRO)
        expect_screen_size_from_file("screenshot-Landscape{2622x1206}.jpg", Platform::IOS).to eq(Devices::IPHONE_17_PRO)
      end

      it "should detect iPhone 17 Pro Max in portrait and landscape based on priority" do
        expect_screen_size_from_file("screenshot-Portrait{1320x2868}.jpg", Platform::IOS).to eq(Devices::IPHONE_17_PRO_MAX)
        expect_screen_size_from_file("screenshot-Landscape{2868x1320}.jpg", Platform::IOS).to eq(Devices::IPHONE_17_PRO_MAX)
      end

      it "should detect iPhone 17 instead of iPhone 17 Pro because of the file name containing device name" do
        expect_screen_size_from_file("Apple iPhone 17-Portrait{1206x2622}.jpg", Platform::IOS).to eq(Devices::IPHONE_17)
        expect_screen_size_from_file("Apple iPhone 17-Landscape{2622x1206}.jpg", Platform::IOS).to eq(Devices::IPHONE_17)
      end

      it "should detect iPhone X instead of iPhone XS because of the file name containing device name" do
        expect_screen_size_from_file("Apple iPhone X-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
        expect_screen_size_from_file("Apple iPhone X-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
      end

      it "should detect iPhone X instead of iPhone XS because of the file name containing device ID" do
        expect_screen_size_from_file("iphone-X-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
        expect_screen_size_from_file("iphone-X-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
      end

      it "should detect iPhone X instead of iPhone XS because of CLI parameters or fastfile" do
        allow(Frameit.config).to receive(:[]).with(:use_legacy_iphonex).and_return(true)
        expect_screen_size_from_file("screenshot-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
        expect_screen_size_from_file("screenshot-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
      end
    end

    describe "valid Android screen sizes" do

      it "should detect Google Pixel 5 in portrait and landscape based on priority" do
        expect_screen_size_from_file("pixel-portrait{1080x2340}.png", Platform::ANDROID).to eq(Devices::GOOGLE_PIXEL_5)
        expect_screen_size_from_file("pixel-landscape{2340x1080}.png", Platform::ANDROID).to eq(Devices::GOOGLE_PIXEL_5)
      end

      it "should detect Google Pixel 3 XL in portrait and landscape based on priority" do
        expect_screen_size_from_file("pixel-portrait{1440x2960}.png", Platform::ANDROID).to eq(Devices::GOOGLE_PIXEL_3_XL)
        expect_screen_size_from_file("pixel-landscape{2960x1440}.png", Platform::ANDROID).to eq(Devices::GOOGLE_PIXEL_3_XL)
      end

      it "should detect Samsung Galaxy S9 because of file name containing device ID" do
        expect_screen_size_from_file("samsung-galaxy-s9-portrait{1440x2960}.png", Platform::ANDROID).to eq(Devices::SAMSUNG_GALAXY_S9)
        expect_screen_size_from_file("samsung-galaxy-s9-landscape{2960x1440}.png", Platform::ANDROID).to eq(Devices::SAMSUNG_GALAXY_S9)
      end

      it "should detect Samsung Galaxy S8 because of file name containing device name" do
        expect_screen_size_from_file("Samsung Galaxy S8 portrait{1440x2960}.png", Platform::ANDROID).to eq(Devices::SAMSUNG_GALAXY_S8)
        expect_screen_size_from_file("Samsung Galaxy S8 landscape{2960x1440}.png", Platform::ANDROID).to eq(Devices::SAMSUNG_GALAXY_S8)
      end
    end

    describe "force device types" do
      it "should force iPhone X despite arbitrary file name and resolution via device ID" do
        expect_forced_screen_size("iphone-X").to eq(Devices::IPHONE_X)
      end

      it "should force iPhone X despite arbitrary file name and resolution via device name" do
        expect_forced_screen_size("iPhone X").to eq(Devices::IPHONE_X)
      end

      it "should force iPhone XS despite arbitrary file name and resolution via display type string" do
        expect_forced_screen_size("iOS-5.8-in").to eq(Devices::IPHONE_XS)
      end

      it "should force iPhone 16 via device ID" do
        expect_forced_screen_size("iphone-16").to eq(Devices::IPHONE_16)
      end

      it "should force iPhone 16 Pro Max via device ID" do
        expect_forced_screen_size("iphone16-pro-max").to eq(Devices::IPHONE_16_PRO_MAX)
      end

      it "should force iPhone 17 via device ID" do
        expect_forced_screen_size("iphone-17").to eq(Devices::IPHONE_17)
      end

      it "should force iPhone 17 via device name" do
        expect_forced_screen_size("iPhone 17").to eq(Devices::IPHONE_17)
      end

      it "should force iPhone 17 via display type string" do
        expect_forced_screen_size("iOS-6.1-in").to eq(Devices::IPHONE_17)
      end

      it "should force iPhone 17 Pro Max via display type string" do
        expect_forced_screen_size("iOS-6.7-in").to eq(Devices::IPHONE_17_PRO_MAX)
      end
    end

    describe "invalid screen sizes" do
      def expect_invalid_screen_size_from_file(file, platform)
        expect do
          Frameit::Device.detect_device(file, platform)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "Unsupported screen size #{screen_size_from(file)} for path '#{file}'")
      end

      it "shouldn't allow arbitrary unsupported resolution 1080x1000" do
        expect_invalid_screen_size_from_file("unsupported-device-NativeResolution{1080x1000}.jpg", Platform::IOS)
        expect_invalid_screen_size_from_file("Apple iPad Air 2{1000x1080}.jpg", Platform::IOS)
      end
    end
  end
end
