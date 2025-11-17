require 'fastimage'

require_relative 'module'
require 'spaceship/connect_api/models/app_screenshot_set'

module Deliver
  # AppScreenshot represents one screenshots for one specific locale and
  # device type.
  class AppScreenshot
    # Shorthand for DisplayType constants
    DisplayType = Spaceship::ConnectAPI::AppScreenshotSet::DisplayType

    # Mapping from DisplayType constants to screen size strings (preserved for backward compatibility)
    DISPLAY_TYPE_TO_SCREEN_SIZE = {
      DisplayType::APP_IPHONE_35 => "iOS-3.5-in",
      DisplayType::APP_IPHONE_40 => "iOS-4-in",
      DisplayType::APP_IPHONE_47 => "iOS-4.7-in",
      DisplayType::APP_IPHONE_55 => "iOS-5.5-in",
      DisplayType::APP_IPHONE_58 => "iOS-5.8-in",
      DisplayType::APP_IPHONE_61 => "iOS-6.1-in",
      DisplayType::APP_IPHONE_65 => "iOS-6.5-in",
      DisplayType::APP_IPHONE_67 => "iOS-6.7-in",
      DisplayType::APP_IPAD_97 => "iOS-iPad",
      DisplayType::APP_IPAD_105 => "iOS-iPad-10.5",
      DisplayType::APP_IPAD_PRO_3GEN_11 => "iOS-iPad-11",
      DisplayType::APP_IPAD_PRO_129 => "iOS-iPad-Pro",
      DisplayType::APP_IPAD_PRO_3GEN_129 => "iOS-iPad-Pro-12.9",
      DisplayType::IMESSAGE_APP_IPHONE_40 => "iOS-4-in-messages",
      DisplayType::IMESSAGE_APP_IPHONE_47 => "iOS-4.7-in-messages",
      DisplayType::IMESSAGE_APP_IPHONE_55 => "iOS-5.5-in-messages",
      DisplayType::IMESSAGE_APP_IPHONE_58 => "iOS-5.8-in-messages",
      DisplayType::IMESSAGE_APP_IPHONE_61 => "iOS-6.1-in-messages",
      DisplayType::IMESSAGE_APP_IPHONE_65 => "iOS-6.5-in-messages",
      DisplayType::IMESSAGE_APP_IPHONE_67 => "iOS-6.7-in-messages",
      DisplayType::IMESSAGE_APP_IPAD_97 => "iOS-iPad-messages",
      DisplayType::IMESSAGE_APP_IPAD_105 => "iOS-iPad-10.5-messages",
      DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_11 => "iOS-iPad-11-messages",
      DisplayType::IMESSAGE_APP_IPAD_PRO_129 => "iOS-iPad-Pro-messages",
      DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_129 => "iOS-iPad-Pro-12.9-messages",
      DisplayType::APP_WATCH_SERIES_3 => "iOS-Apple-Watch",
      DisplayType::APP_WATCH_SERIES_4 => "iOS-Apple-Watch-Series4",
      DisplayType::APP_WATCH_SERIES_7 => "iOS-Apple-Watch-Series7",
      DisplayType::APP_WATCH_ULTRA => "iOS-Apple-Watch-Ultra",
      DisplayType::APP_APPLE_TV => "Apple-TV",
      DisplayType::APP_DESKTOP => "Mac"
    }.freeze

    FORMATTED_NAMES = {
      DisplayType::APP_IPHONE_35 => "iPhone 4",
      DisplayType::APP_IPHONE_40 => "iPhone 5",
      DisplayType::APP_IPHONE_47 => "iPhone 6", # also 7 & 8
      DisplayType::APP_IPHONE_55 => "iPhone 6 Plus", # also 7 Plus & 8 Plus
      DisplayType::APP_IPHONE_58 => "iPhone XS",
      DisplayType::APP_IPHONE_61 => "iPhone 14 Pro",
      DisplayType::APP_IPHONE_65 => "iPhone XS Max",
      DisplayType::APP_IPHONE_67 => "iPhone 14 Pro Max",
      DisplayType::APP_IPAD_97 => "iPad",
      DisplayType::APP_IPAD_105 => "iPad 10.5",
      DisplayType::APP_IPAD_PRO_3GEN_11 => "iPad 11",
      DisplayType::APP_IPAD_PRO_129 => "iPad Pro",
      DisplayType::APP_IPAD_PRO_3GEN_129 => "iPad Pro (12.9-inch) (3rd generation)",
      DisplayType::IMESSAGE_APP_IPHONE_40 => "iPhone 5 (iMessage)",
      DisplayType::IMESSAGE_APP_IPHONE_47 => "iPhone 6 (iMessage)", # also 7 & 8
      DisplayType::IMESSAGE_APP_IPHONE_55 => "iPhone 6 Plus (iMessage)", # also 7 Plus & 8 Plus
      DisplayType::IMESSAGE_APP_IPHONE_58 => "iPhone XS (iMessage)",
      DisplayType::IMESSAGE_APP_IPHONE_61 => "iPhone 14 Pro (iMessage)",
      DisplayType::IMESSAGE_APP_IPHONE_65 => "iPhone XS Max (iMessage)",
      DisplayType::IMESSAGE_APP_IPHONE_67 => "iPhone 14 Pro Max (iMessage)",
      DisplayType::IMESSAGE_APP_IPAD_97 => "iPad (iMessage)",
      DisplayType::IMESSAGE_APP_IPAD_PRO_129 => "iPad Pro (iMessage)",
      DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_129 => "iPad Pro (12.9-inch) (3rd generation) (iMessage)",
      DisplayType::IMESSAGE_APP_IPAD_105 => "iPad 10.5 (iMessage)",
      DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_11 => "iPad 11 (iMessage)",
      DisplayType::APP_DESKTOP => "Mac",
      DisplayType::APP_WATCH_SERIES_3 => "Watch",
      DisplayType::APP_WATCH_SERIES_4 => "Watch Series4",
      DisplayType::APP_WATCH_SERIES_7 => "Watch Series7",
      DisplayType::APP_WATCH_ULTRA => "Watch Ultra",
      DisplayType::APP_APPLE_TV => "Apple TV"
    }.freeze

    # reference: https://help.apple.com/app-store-connect/#/devd274dd925
    # This list does not include iPad Pro 12.9-inch (3rd generation)
    # because it has same resolution as APP_IPAD_PRO_129 and will clobber.
    # Returns a hash mapping DisplayType constants to their supported resolutions.
    DEVICE_RESOLUTIONS = {
      DisplayType::APP_IPHONE_67 => [
        [1290, 2796],
        [2796, 1290]
      ],
      DisplayType::APP_IPHONE_65 => [
        [1242, 2688],
        [2688, 1242],
        [1284, 2778],
        [2778, 1284]
      ],
      DisplayType::APP_IPHONE_61 => [
        [1179, 2556],
        [2556, 1179]
      ],
      DisplayType::APP_IPHONE_58 => [
        [1125, 2436],
        [2436, 1125],
        [1170, 2532],
        [2532, 1170]
      ],
      DisplayType::APP_IPHONE_55 => [
        [1242, 2208],
        [2208, 1242]
      ],
      DisplayType::APP_IPHONE_47 => [
        [750, 1334],
        [1334, 750]
      ],
      DisplayType::APP_IPHONE_40 => [
        [640, 1096],
        [640, 1136],
        [1136, 600],
        [1136, 640]
      ],
      DisplayType::APP_IPHONE_35 => [
        [640, 920],
        [640, 960],
        [960, 600],
        [960, 640]
      ],
      DisplayType::APP_IPAD_97 => [ # 9.7 inch
        [1024, 748],
        [1024, 768],
        [2048, 1496],
        [2048, 1536],
        [768, 1004], # portrait without status bar
        [768, 1024],
        [1536, 2008], # portrait without status bar
        [1536, 2048]
      ],
      DisplayType::APP_IPAD_105 => [
        [1668, 2224],
        [2224, 1668]
      ],
      DisplayType::APP_IPAD_PRO_3GEN_11 => [
        [1668, 2388],
        [2388, 1668]
      ],
      DisplayType::APP_IPAD_PRO_129 => [
        [2732, 2048],
        [2048, 2732]
      ],
      DisplayType::APP_DESKTOP => [
        [1280, 800],
        [1440, 900],
        [2560, 1600],
        [2880, 1800]
      ],
      DisplayType::APP_WATCH_SERIES_3 => [
        [312, 390]
      ],
      DisplayType::APP_WATCH_SERIES_4 => [
        [368, 448]
      ],
      DisplayType::APP_WATCH_SERIES_7 => [
        [396, 484]
      ],
      DisplayType::APP_WATCH_ULTRA => [
        [410, 502]
      ],
      DisplayType::APP_APPLE_TV => [
        [1920, 1080],
        [3840, 2160]
      ]
    }.freeze

    DEVICE_RESOLUTIONS_MESSAGES = {
      DisplayType::IMESSAGE_APP_IPHONE_40 => DEVICE_RESOLUTIONS[DisplayType::APP_IPHONE_40],
      DisplayType::IMESSAGE_APP_IPHONE_47 => DEVICE_RESOLUTIONS[DisplayType::APP_IPHONE_47],
      DisplayType::IMESSAGE_APP_IPHONE_55 => DEVICE_RESOLUTIONS[DisplayType::APP_IPHONE_55],
      DisplayType::IMESSAGE_APP_IPHONE_58 => DEVICE_RESOLUTIONS[DisplayType::APP_IPHONE_58],
      DisplayType::IMESSAGE_APP_IPHONE_61 => DEVICE_RESOLUTIONS[DisplayType::APP_IPHONE_61],
      DisplayType::IMESSAGE_APP_IPHONE_65 => DEVICE_RESOLUTIONS[DisplayType::APP_IPHONE_65],
      DisplayType::IMESSAGE_APP_IPHONE_67 => DEVICE_RESOLUTIONS[DisplayType::APP_IPHONE_67],
      DisplayType::IMESSAGE_APP_IPAD_97 => DEVICE_RESOLUTIONS[DisplayType::APP_IPAD_97],
      DisplayType::IMESSAGE_APP_IPAD_105 => DEVICE_RESOLUTIONS[DisplayType::APP_IPAD_105],
      DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_11 => DEVICE_RESOLUTIONS[DisplayType::APP_IPAD_PRO_3GEN_11],
      DisplayType::IMESSAGE_APP_IPAD_PRO_129 => DEVICE_RESOLUTIONS[DisplayType::APP_IPAD_PRO_129],
      DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_129 => DEVICE_RESOLUTIONS[DisplayType::APP_IPAD_PRO_129]
    }.freeze

    # @return [Spaceship::ConnectAPI::AppScreenshotSet::DisplayType] the display type
    attr_accessor :display_type

    attr_accessor :path

    attr_accessor :language

    # @param path (String) path to the screenshot file
    # @param language (String) Language of this screenshot (e.g. English)
    def initialize(path, language)
      self.path = path
      self.language = language
      self.display_type = self.class.calculate_display_type(path)
    end

    # Nice name
    def formatted_name
      return FORMATTED_NAMES[self.display_type]
    end

    # Validates the given screenshots (size and format)
    def is_valid?
      UI.deprecated('Deliver::AppScreenshot#is_valid? is deprecated in favor of Deliver::AppScreenshotValidator')
      return false unless ["png", "PNG", "jpg", "JPG", "jpeg", "JPEG"].include?(self.path.split(".").last)

      return self.display_type == self.class.calculate_display_type(self.path)
    end

    def is_messages?
      return DisplayType::ALL_IMESSAGE.include?(self.display_type)
    end

    def self.resolve_ipadpro_conflict_if_needed(display_type, filename)
      is_3rd_gen = [
        "iPad Pro (12.9-inch) (3rd generation)", # Default simulator has this name
        "iPad Pro (12.9-inch) (4th generation)", # Default simulator has this name
        "iPad Pro (12.9-inch) (5th generation)", # Default simulator has this name
        "iPad Pro (12.9-inch) (6th generation)", # Default simulator has this name
        "IPAD_PRO_3GEN_129", # Screenshots downloaded from App Store Connect has this name
        "ipadPro129" # Legacy: screenshots downloaded from iTunes Connect used to have this name
      ].any? { |key| filename.include?(key) }
      if is_3rd_gen
        if display_type == DisplayType::APP_IPAD_PRO_129
          return DisplayType::APP_IPAD_PRO_3GEN_129
        elsif display_type == DisplayType::IMESSAGE_APP_IPAD_PRO_129
          return DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_129
        end
      end
      display_type
    end

    def self.calculate_display_type(path)
      size = FastImage.size(path)

      UI.user_error!("Could not find or parse file at path '#{path}'") if size.nil? || size.count == 0

      # iMessage screenshots have same resolution as app screenshots so we need to distinguish them
      path_component = Pathname.new(path).each_filename.to_a[-3]
      devices = path_component.eql?("iMessage") ? DEVICE_RESOLUTIONS_MESSAGES : DEVICE_RESOLUTIONS

      devices.each do |display_type, resolutions|
        if resolutions.include?(size)
          filename = Pathname.new(path).basename.to_s
          return resolve_ipadpro_conflict_if_needed(display_type, filename)
        end
      end

      nil
    end
  end
end
