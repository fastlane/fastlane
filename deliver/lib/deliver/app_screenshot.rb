require 'fastimage'

require_relative 'module'

module Deliver
  # AppScreenshot represents one screenshots for one specific locale and
  # device type.
  class AppScreenshot
    #
    module ScreenSize
      # iPhone 4
      IOS_35 = "iOS-3.5-in"
      # iPhone 5
      IOS_40 = "iOS-4-in"
      # iPhone 6, 7, & 8
      IOS_47 = "iOS-4.7-in"
      # iPhone 6 Plus, 7 Plus, & 8 Plus
      IOS_55 = "iOS-5.5-in"
      # iPhone XS
      IOS_58 = "iOS-5.8-in"
      # iPhone XR
      IOS_61 = "iOS-6.1-in"
      # iPhone XS Max
      IOS_65 = "iOS-6.5-in"

      # iPad
      IOS_IPAD = "iOS-iPad"
      # iPad 10.5
      IOS_IPAD_10_5 = "iOS-iPad-10.5"
      # iPad 11
      IOS_IPAD_11 = "iOS-iPad-11"
      # iPad Pro
      IOS_IPAD_PRO = "iOS-iPad-Pro"
      # iPad Pro (12.9-inch) (3rd generation)
      IOS_IPAD_PRO_12_9 = "iOS-iPad-Pro-12.9"

      # iPhone 5 iMessage
      IOS_40_MESSAGES = "iOS-4-in-messages"
      # iPhone 6, 7, & 8 iMessage
      IOS_47_MESSAGES = "iOS-4.7-in-messages"
      # iPhone 6 Plus, 7 Plus, & 8 Plus iMessage
      IOS_55_MESSAGES = "iOS-5.5-in-messages"
      # iPhone XS iMessage
      IOS_58_MESSAGES = "iOS-5.8-in-messages"
      # iPhone XR iMessage
      IOS_61_MESSAGES = "iOS-6.1-in-messages"
      # iPhone XS Max iMessage
      IOS_65_MESSAGES = "iOS-6.5-in-messages"

      # iPad iMessage
      IOS_IPAD_MESSAGES = "iOS-iPad-messages"
      # iPad 10.5 iMessage
      IOS_IPAD_10_5_MESSAGES = "iOS-10.5-messages"
      # iPad 11 iMessage
      IOS_IPAD_11_MESSAGES = "iOS-11-messages"
      # iPad Pro iMessage
      IOS_IPAD_PRO_MESSAGES = "iOS-iPad-Pro-messages"
      # iPad Pro (12.9-inch) (3rd generation) iMessage
      IOS_IPAD_PRO_12_9_MESSAGES = "iOS-iPad-Pro-12.9-messages"

      # Apple Watch
      IOS_APPLE_WATCH = "iOS-Apple-Watch"
      # Apple Watch Series 4
      IOS_APPLE_WATCH_SERIES4 = "iOS-Apple-Watch-Series4"

      # Apple TV
      APPLE_TV = "Apple-TV"

      # Mac
      MAC = "Mac"
    end

    # @return [Deliver::ScreenSize] the screen size (device type)
    #  specified at {Deliver::ScreenSize}
    attr_accessor :screen_size

    attr_accessor :path

    attr_accessor :language

    # @param path (String) path to the screenshot file
    # @param language (String) Language of this screenshot (e.g. English)
    # @param screen_size (Deliver::AppScreenshot::ScreenSize) the screen size, which
    #  will automatically be calculated when you don't set it.
    def initialize(path, language, screen_size = nil)
      self.path = path
      self.language = language
      screen_size ||= self.class.calculate_screen_size(path)

      self.screen_size = screen_size

      UI.error("Looks like the screenshot given (#{path}) does not match the requirements of #{screen_size}") unless self.is_valid?
    end

    # The iTC API requires a different notation for the device
    def device_type
      matching = {
        ScreenSize::IOS_35 => "iphone35",
        ScreenSize::IOS_40 => "iphone4",
        ScreenSize::IOS_47 => "iphone6", # also 7 and 8
        ScreenSize::IOS_55 => "iphone6Plus", # also 7 Plus & 8 Plus
        ScreenSize::IOS_58 => "iphone58",
        ScreenSize::IOS_65 => "iphone65",
        ScreenSize::IOS_IPAD => "ipad",
        ScreenSize::IOS_IPAD_10_5 => "ipad105",
        ScreenSize::IOS_IPAD_11 => "ipadPro11",
        ScreenSize::IOS_IPAD_PRO => "ipadPro",
        ScreenSize::IOS_IPAD_PRO_12_9 => "ipadPro129",
        ScreenSize::IOS_40_MESSAGES => "iphone4",
        ScreenSize::IOS_47_MESSAGES => "iphone6", # also 7 & 8
        ScreenSize::IOS_55_MESSAGES => "iphone6Plus", # also 7 Plus & 8 Plus
        ScreenSize::IOS_58_MESSAGES => "iphone58",
        ScreenSize::IOS_65_MESSAGES => "iphone65",
        ScreenSize::IOS_IPAD_MESSAGES => "ipad",
        ScreenSize::IOS_IPAD_PRO_MESSAGES => "ipadPro",
        ScreenSize::IOS_IPAD_PRO_12_9_MESSAGES => "ipadPro129",
        ScreenSize::IOS_IPAD_10_5_MESSAGES => "ipad105",
        ScreenSize::IOS_IPAD_11_MESSAGES => "ipadPro11",
        ScreenSize::MAC => "desktop",
        ScreenSize::IOS_APPLE_WATCH => "watch",
        ScreenSize::IOS_APPLE_WATCH_SERIES4 => "watchSeries4",
        ScreenSize::APPLE_TV => "appleTV"
      }
      return matching[self.screen_size]
    end

    # Nice name
    def formatted_name
      matching = {
        ScreenSize::IOS_35 => "iPhone 4",
        ScreenSize::IOS_40 => "iPhone 5",
        ScreenSize::IOS_47 => "iPhone 6", # and 7
        ScreenSize::IOS_55 => "iPhone 6 Plus", # and 7 Plus
        ScreenSize::IOS_58 => "iPhone XS",
        ScreenSize::IOS_61 => "iPhone XR",
        ScreenSize::IOS_65 => "iPhone XS Max",
        ScreenSize::IOS_IPAD => "iPad",
        ScreenSize::IOS_IPAD_10_5 => "iPad 10.5",
        ScreenSize::IOS_IPAD_11 => "iPad 11",
        ScreenSize::IOS_IPAD_PRO => "iPad Pro",
        ScreenSize::IOS_IPAD_PRO_12_9 => "iPad Pro (12.9-inch) (3rd generation)",
        ScreenSize::IOS_40_MESSAGES => "iPhone 5 (iMessage)",
        ScreenSize::IOS_47_MESSAGES => "iPhone 6 (iMessage)", # also 7 & 8
        ScreenSize::IOS_55_MESSAGES => "iPhone 6 Plus (iMessage)", # also 7 Plus & 8 Plus
        ScreenSize::IOS_58_MESSAGES => "iPhone XS (iMessage)",
        ScreenSize::IOS_61_MESSAGES => "iPhone XR (iMessage)",
        ScreenSize::IOS_65_MESSAGES => "iPhone XS Max (iMessage)",
        ScreenSize::IOS_IPAD_MESSAGES => "iPad (iMessage)",
        ScreenSize::IOS_IPAD_PRO_MESSAGES => "iPad Pro (iMessage)",
        ScreenSize::IOS_IPAD_PRO_12_9_MESSAGES => "iPad Pro (12.9-inch) (3rd generation) (iMessage)",
        ScreenSize::IOS_IPAD_10_5_MESSAGES => "iPad 10.5 (iMessage)",
        ScreenSize::IOS_IPAD_11_MESSAGES => "iPad 11 (iMessage)",
        ScreenSize::MAC => "Mac",
        ScreenSize::IOS_APPLE_WATCH => "Watch",
        ScreenSize::IOS_APPLE_WATCH_SERIES4 => "Watch Series4",
        ScreenSize::APPLE_TV => "Apple TV"
      }
      return matching[self.screen_size]
    end

    # Validates the given screenshots (size and format)
    def is_valid?
      return false unless ["png", "PNG", "jpg", "JPG", "jpeg", "JPEG"].include?(self.path.split(".").last)

      return self.screen_size == self.class.calculate_screen_size(self.path)
    end

    def is_messages?
      return [
        ScreenSize::IOS_40_MESSAGES,
        ScreenSize::IOS_47_MESSAGES,
        ScreenSize::IOS_55_MESSAGES,
        ScreenSize::IOS_58_MESSAGES,
        ScreenSize::IOS_65_MESSAGES,
        ScreenSize::IOS_IPAD_MESSAGES,
        ScreenSize::IOS_IPAD_PRO_MESSAGES,
        ScreenSize::IOS_IPAD_PRO_12_9_MESSAGES,
        ScreenSize::IOS_IPAD_10_5_MESSAGES,
        ScreenSize::IOS_IPAD_11_MESSAGES
      ].include?(self.screen_size)
    end

    def self.device_messages
      # This list does not include iPad Pro 12.9-inch (3rd generation)
      # because it has same resoluation as IOS_IPAD_PRO and will clobber
      return {
        ScreenSize::IOS_65_MESSAGES => [
          [1242, 2688],
          [2688, 1242]
        ],
        ScreenSize::IOS_61_MESSAGES => [
          [828, 1792],
          [1792, 828]
        ],
        ScreenSize::IOS_58_MESSAGES => [
          [1125, 2436],
          [2436, 1125]
        ],
        ScreenSize::IOS_55_MESSAGES => [
          [1242, 2208],
          [2208, 1242]
        ],
        ScreenSize::IOS_47_MESSAGES => [
          [750, 1334],
          [1334, 750]
        ],
        ScreenSize::IOS_40_MESSAGES => [
          [640, 1096],
          [640, 1136],
          [1136, 600],
          [1136, 640]
        ],
        ScreenSize::IOS_IPAD_MESSAGES => [
          [1024, 748],
          [1024, 768],
          [2048, 1496],
          [2048, 1536],
          [768, 1004],
          [768, 1024],
          [1536, 2008],
          [1536, 2048]
        ],
        ScreenSize::IOS_IPAD_10_5_MESSAGES => [
          [1668, 2224],
          [2224, 1668]
        ],
        ScreenSize::IOS_IPAD_11_MESSAGES => [
          [1668, 2388],
          [2388, 1668]
        ],
        ScreenSize::IOS_IPAD_PRO_MESSAGES => [
          [2732, 2048],
          [2048, 2732]
        ]
      }
    end

    # reference: https://help.apple.com/app-store-connect/#/devd274dd925
    def self.devices
      # This list does not include iPad Pro 12.9-inch (3rd generation)
      # because it has same resoluation as IOS_IPAD_PRO and will clobber
      return {
        ScreenSize::IOS_65 => [
          [1242, 2688],
          [2688, 1242]
        ],
        ScreenSize::IOS_61 => [
          [828, 1792],
          [1792, 828]
        ],
        ScreenSize::IOS_58 => [
          [1125, 2436],
          [2436, 1125]
        ],
        ScreenSize::IOS_55 => [
          [1242, 2208],
          [2208, 1242]
        ],
        ScreenSize::IOS_47 => [
          [750, 1334],
          [1334, 750]
        ],
        ScreenSize::IOS_40 => [
          [640, 1096],
          [640, 1136],
          [1136, 600],
          [1136, 640]
        ],
        ScreenSize::IOS_35 => [
          [640, 920],
          [640, 960],
          [960, 600],
          [960, 640]
        ],
        ScreenSize::IOS_IPAD => [ # 9.7 inch
          [1024, 748],
          [1024, 768],
          [2048, 1496],
          [2048, 1536],
          [768, 1004], # portrait without status bar
          [768, 1024],
          [1536, 2008], # portrait without status bar
          [1536, 2048]
        ],
        ScreenSize::IOS_IPAD_10_5 => [
          [1668, 2224],
          [2224, 1668]
        ],
        ScreenSize::IOS_IPAD_11 => [
          [1668, 2388],
          [2388, 1668]
        ],
        ScreenSize::IOS_IPAD_PRO => [
          [2732, 2048],
          [2048, 2732]
        ],
        ScreenSize::MAC => [
          [1280, 800],
          [1440, 900],
          [2560, 1600],
          [2880, 1800]
        ],
        ScreenSize::IOS_APPLE_WATCH => [
          [312, 390]
        ],
        ScreenSize::IOS_APPLE_WATCH_SERIES4 => [
          [368, 448]
        ],
        ScreenSize::APPLE_TV => [
          [1920, 1080],
          [3840, 2160]
        ]
      }
    end

    def self.resolve_ipadpro_conflict_if_needed(screen_size, filename)
      is_3rd_gen = [
        "iPad Pro (12.9-inch) (3rd generation)", # default simulator name has this
        "iPad Pro (12.9-inch) (4th generation)", # default simulator name has this
        "ipadPro129" # downloaded screenshots name has this
      ].any? { |key| filename.include?(key) }
      if is_3rd_gen
        if screen_size == ScreenSize::IOS_IPAD_PRO
          return ScreenSize::IOS_IPAD_PRO_12_9
        elsif screen_size == ScreenSize::IOS_IPAD_PRO_MESSAGES
          return ScreenSize::IOS_IPAD_PRO_12_9_MESSAGES
        end
      end
      screen_size
    end

    def self.calculate_screen_size(path)
      size = FastImage.size(path)

      UI.user_error!("Could not find or parse file at path '#{path}'") if size.nil? || size.count == 0

      # iMessage screenshots have same resolution as app screenshots so we need to distinguish them
      path_component = Pathname.new(path).each_filename.to_a[-3]
      devices = path_component.eql?("iMessage") ? self.device_messages : self.devices

      devices.each do |screen_size, resolutions|
        if resolutions.include?(size)
          filename = Pathname.new(path).basename.to_s
          return resolve_ipadpro_conflict_if_needed(screen_size, filename)
        end
      end

      UI.user_error!("Unsupported screen size #{size} for path '#{path}'")
    end
  end

  ScreenSize = AppScreenshot::ScreenSize
end
