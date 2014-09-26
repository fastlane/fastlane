module IosDeployKit
  module ScreenSize
    IOS_35 = "iOS-3.5-in"
    IOS_40 = "iOS-4-in"
    IOS_47 = "iOS-4.7-in"
    IOS_55 = "iOS-5.5-in"
    IOS_IPAD = "iOS-iPad"
  end

  class AppScreenshot < MetadataItem
    attr_accessor :screen_size
    def initialize(path, screen_size)
      super(path)

      self.screen_size = screen_size
    end

    def create_xml_node(doc, order_index)
      node = super(doc)
      
      # Screenshots have a slightly different xml code

      # <software_screenshot display_target="iOS-4-in" position="1">
      #     <size>295276</size>
      #     <file_name>1-en-4-StartScreen.png.png</file_name>
      #     <checksum type="md5">c00bd122a3ffbc79e26f1ae6210c7efd</checksum>
      # </software_screenshot>


      node['display_target'] = self.screen_size
      node['position'] = order_index

      return node
    end

    def name_for_xml_node
      'software_screenshot'
    end
  end
end