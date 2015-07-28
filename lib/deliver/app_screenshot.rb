require 'fastimage'


module Deliver
  # AppScreenshot represents one screenshots for one specific locale and 
  # device type.
  class AppScreenshot < MetadataItem
    module ScreenSize
      # iPhone 4
      IOS_35 = "iOS-3.5-in"
      # iPhone 5
      IOS_40 = "iOS-4-in"
      # iPhone 6
      IOS_47 = "iOS-4.7-in"
      # iPhone 6 Plus
      IOS_55 = "iOS-5.5-in"
      # iPad
      IOS_IPAD = "iOS-iPad"
      #  Watch
      IOS_APPLE_WATCH= "iOS-Apple-Watch"
      # Mac
      MAC = "Mac"
    end

    # @return [Deliver::ScreenSize] the screen size (device type)
    #  specified at {Deliver::ScreenSize}
    attr_accessor :screen_size

    # @param path (String) path to the screenshot file
    # @param screen_size (Deliver::AppScreenshot::ScreenSize) the screen size, which
    #  will automatically be calculated when you don't set it.
    def initialize(path, screen_size = nil)
      super(path)

      screen_size ||= self.class.calculate_screen_size(path)

      self.screen_size = screen_size

      Helper.log.error "Looks like the screenshot given (#{path}) does not match the requirements of #{screen_size}" unless self.is_valid?
    end

    def create_xml_node(doc, order_index)
      node = super(doc)
      
      # Screenshots have a slightly different xml code

      # <software_screenshot display_target="iOS-4-in" position="1">
      #     <size>295276</size>
      #     <file_name>1-en-4-StartScreen.png</file_name>
      #     <checksum type="md5">c00bd122a3ffbc79e26f1ae6210c7efd</checksum>
      # </software_screenshot>


      node['display_target'] = self.screen_size
      node['position'] = order_index

      return node
    end

    def name_for_xml_node
      'software_screenshot'
    end

    # Validates the given screenshots (size and format)
    def is_valid?
      return false unless ["png", "PNG", "jpg", "JPG", "jpeg", "JPEG"].include? self.path.split(".").last

      size = FastImage.size(self.path)

      return self.screen_size == self.class.calculate_screen_size(self.path)
    end

    def self.calculate_screen_size(path)
      size = FastImage.size(path)

      raise "Could not find or parse file at path '#{path}'" if (size == nil or size.count == 0)

      devices = {
        ScreenSize::IOS_55 => [
          [1080, 1920],
          [1242, 2208]
        ],
        ScreenSize::IOS_47 => [
          [750, 1334]
        ],
        ScreenSize::IOS_40 => [
          [640, 1136],
          [640, 1096],
          [1136, 600] # landscape status bar is smaller
        ],
        ScreenSize::IOS_35 => [
          [640, 960],
          [640, 920],
          [960, 600] # landscape status bar is smaller
        ],
        ScreenSize::IOS_IPAD => [
          [1024, 748],
          [1024, 768],
          [2048, 1496],
          [2048, 1536],
          [768, 1004],
          [768, 1024],
          [1536, 2008],
          [1536, 2048]
        ],
        ScreenSize::MAC => [
          [1280, 800],
          [1440, 900],
          [2880, 1800],
          [2560, 1600]
        ],
        ScreenSize::IOS_APPLE_WATCH=> [
          [312, 390]
        ]
      }

      devices.each do |device_type, array|
        array.each do |resolution|
          if (size[0] == resolution[0] and size[1] == resolution[1]) or # portrait
              (size[1] == resolution[0] and size[0] == resolution[1]) # landscape
            return device_type
          end
        end
      end

      raise "Unsupported screen size #{size} for path '#{path}'".red
    end
  end

  ScreenSize = AppScreenshot::ScreenSize
end