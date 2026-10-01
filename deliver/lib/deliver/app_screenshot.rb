require 'fastimage'

require_relative 'module'
require 'spaceship/connect_api/models/app_screenshot_set'

module Deliver
  # AppScreenshot represents one screenshots for one specific locale and
  # device type.
  class AppScreenshot
    # Shorthand for DisplayType constants
    DisplayType = Spaceship::ConnectAPI::AppScreenshotSet::DisplayType

    FORMATTED_NAMES = {
      DisplayType::APP_IPHONE_35 => "iPhone 4",
      DisplayType::APP_IPHONE_40 => "iPhone 5",
      DisplayType::APP_IPHONE_47 => "iPhone 6",
      DisplayType::APP_IPHONE_55 => "iPhone 6 Plus",
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
      DisplayType::IMESSAGE_APP_IPHONE_47 => "iPhone 6 (iMessage)",
      DisplayType::IMESSAGE_APP_IPHONE_55 => "iPhone 6 Plus (iMessage)",
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
      DisplayType::APP_WATCH_SERIES_10 => "Watch Series10",
      DisplayType::APP_WATCH_ULTRA => "Watch Ultra",
      DisplayType::APP_APPLE_TV => "Apple TV",
      DisplayType::APP_APPLE_VISION_PRO => "Vision Pro"
    }.freeze

    # reference: https://help.apple.com/app-store-connect/#/devd274dd925
    # Returns a hash mapping DisplayType constants to their supported resolutions.
    DEVICE_RESOLUTIONS = {
      # These are actually 6.9" iPhones
      DisplayType::APP_IPHONE_67 => [
        [1260, 2736],
        [2736, 1260],
        [1290, 2796],
        [2796, 1290],
        [1320, 2868],
        [2868, 1320]
      ],
      DisplayType::APP_IPHONE_65 => [
        [1242, 2688],
        [2688, 1242],
        [1284, 2778],
        [2778, 1284]
      ],
      # These are actually 6.3" iPhones
      DisplayType::APP_IPHONE_61 => [
        [1179, 2556],
        [2556, 1179],
        [1206, 2622],
        [2622, 1206]
      ],
      # These are actually 6.1" iPhones
      DisplayType::APP_IPHONE_58 => [
        [1170, 2532],
        [2532, 1170],
        [1125, 2436],
        [2436, 1125],
        [1080, 2340],
        [2340, 1080]
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
      DisplayType::APP_IPAD_97 => [
        [1024, 748],
        [1024, 768],
        [2048, 1496],
        [2048, 1536],
        [768, 1004],
        [768, 1024],
        [1536, 2008],
        [1536, 2048]
      ],
      DisplayType::APP_IPAD_105 => [
        [1668, 2224],
        [2224, 1668]
      ],
      DisplayType::APP_IPAD_PRO_3GEN_11 => [
        [1488, 2266],
        [2266, 1488],
        [1668, 2420],
        [2420, 1668],
        [1668, 2388],
        [2388, 1668],
        [1640, 2360],
        [2360, 1640]
      ],
      # These are 12.9" iPads
      DisplayType::APP_IPAD_PRO_129 => [
        [2048, 2732],
        [2732, 2048]
      ],
      # These are actually 13" iPads
      DisplayType::APP_IPAD_PRO_3GEN_129 => [
        [2048, 2732],
        [2732, 2048],
        [2064, 2752],
        [2752, 2064]
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
      DisplayType::APP_WATCH_SERIES_10 => [
        [416, 496]
      ],
      DisplayType::APP_WATCH_ULTRA => [
        [410, 502],
        [422, 514]
      ],
      DisplayType::APP_APPLE_TV => [
        [1920, 1080],
        [3840, 2160]
      ],
      DisplayType::APP_APPLE_VISION_PRO => [
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
      DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_129 => DEVICE_RESOLUTIONS[DisplayType::APP_IPAD_PRO_3GEN_129]
    }.freeze

    # Resolutions that are shared by multiple device types
    CONFLICTING_RESOLUTIONS = [
      # iPad Pro 12.9" (2nd gen) and iPad Pro 13" (3rd+ gen)
      [2048, 2732],
      [2732, 2048],
      # Apple TV and Apple Vision Pro
      [3840, 2160]
    ].freeze

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
      # rubocop:disable Require/MissingRequireStatement
      return DisplayType::ALL_IMESSAGE.include?(self.display_type)
      # rubocop:enable Require/MissingRequireStatement
    end

    def self.calculate_display_type(path)
      size = FastImage.size(path)
      UI.user_error!("Could not find or parse file at path '#{path}'") if size.nil? || size.count == 0

      path_component = Pathname.new(path).each_filename.to_a[-3]
      is_imessage = path_component.eql?("iMessage")
      devices = is_imessage ? DEVICE_RESOLUTIONS_MESSAGES : DEVICE_RESOLUTIONS

      matching_display_type = devices.find { |_display_type, resolutions| resolutions.include?(size) }&.first

      return nil unless matching_display_type

      return matching_display_type unless CONFLICTING_RESOLUTIONS.include?(size)

      path_lower = path.downcase

      case size
      # iPad Pro conflict
      when [2048, 2732], [2732, 2048]
        is_2gen = path_lower.include?("app_ipad_pro_129") ||
                  (path_lower.include?("12.9") && path_lower.include?("2nd generation")) # e.g. iPad Pro (12.9-inch) (2nd generation)

        # rubocop:disable Require/MissingRequireStatement
        if is_2gen
          return is_imessage ? DisplayType::IMESSAGE_APP_IPAD_PRO_129 : DisplayType::APP_IPAD_PRO_129
        else
          return is_imessage ? DisplayType::IMESSAGE_APP_IPAD_PRO_3GEN_129 : DisplayType::APP_IPAD_PRO_3GEN_129
        end
      # Apple TV vs Vision Pro conflict
      when [3840, 2160]
        return path_lower.include?("vision") ? DisplayType::APP_APPLE_VISION_PRO : DisplayType::APP_APPLE_TV
        # rubocop:enable Require/MissingRequireStatement
      else
        matching_display_type
      end
    end
  end
end
