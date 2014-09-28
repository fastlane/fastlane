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

    def initialize(path, screen_size)
      super(path)

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
      return false unless self.path.split(".").last == "png"

      size = FastImage.size(self.path)

      # TODO: Support landscape screenshots
      case self.screen_size
        when ScreenSize::IOS_55
          return (size[0] == 1080 and size[1] == 1920)
        when ScreenSize::IOS_47
          return (size[0] == 750 and size[1] == 1334)
        when ScreenSize::IOS_40
          return (size[0] == 640 and size[1] == 1136)
        when ScreenSize::IOS_35
          return (size[0] == 640 and size[1] == 960)
        when ScreenSize::IOS_IPAD
          return (size[0] == 1536 and size[1] == 2048)
        else
          Helper.log.error "Unsupported screen size #{self.screen_size}"
          return false
      end
    end
  end

  ScreenSize = AppScreenshot::ScreenSize
end