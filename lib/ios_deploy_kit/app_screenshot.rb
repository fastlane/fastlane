require 'fastimage'


module IosDeployKit
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
    end

    # @return [IosDeployKit::ScreenSize] the screen size (device type) 
    #  specified at {IosDeployKit::ScreenSize}
    attr_accessor :screen_size

    # @param path (String) path to the screenshot file
    # @param screen_size (IosDeployKit::AppScreenshot::ScreenSize) the screen size, which
    #  will automatically be calculated when you don't set it.
    def initialize(path, screen_size = nil)
      super(path)

      screen_size ||= self.class.calculate_screen_size(path)

      self.screen_size = screen_size

      # TODO: change to exception
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
      return false unless self.path.split(".").last == "png"

      size = FastImage.size(self.path)

      return self.screen_size == self.class.calculate_screen_size(self.path)
    end

    def self.calculate_screen_size(path)
      size = FastImage.size(path)

      raise "Could not find or parse file at path '#{path}'" if (size == nil or size.count == 0)

      if (size[0] == 1080 and size[1] == 1920) or (size[0] == 1242 and size[1] == 2208)
        ScreenSize::IOS_55
      elsif (size[0] == 750 and size[1] == 1334)
        ScreenSize::IOS_47
      elsif (size[0] == 640 and size[1] == 1136)
        ScreenSize::IOS_40
      elsif (size[0] == 640 and size[1] == 960)
        ScreenSize::IOS_35
      elsif (size[0] == 1536 and size[1] == 2048)
        ScreenSize::IOS_IPAD
      else
        error = "Unsupported screen size #{size} for path '#{path}'"
        Helper.log.error error
        raise error
      end
    end
  end

  ScreenSize = AppScreenshot::ScreenSize
end