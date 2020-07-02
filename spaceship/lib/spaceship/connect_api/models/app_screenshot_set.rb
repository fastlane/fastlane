require_relative '../model'
require_relative './app_screenshot'

module Spaceship
  class ConnectAPI
    class AppScreenshotSet
      include Spaceship::ConnectAPI::Model

      attr_accessor :screenshot_display_type

      attr_accessor :app_screenshots

      module DisplayType
        APP_IPHONE_35 = "APP_IPHONE_35"
        APP_IPHONE_40 = "APP_IPHONE_40"
        APP_IPHONE_47 = "APP_IPHONE_47"
        APP_IPHONE_55 = "APP_IPHONE_55"
        APP_IPHONE_58 = "APP_IPHONE_58"
        APP_IPHONE_65 = "APP_IPHONE_65"

        APP_IPAD_97 = "APP_IPAD_97"
        APP_IPAD_105 = "APP_IPAD_105"
        APP_IPAD_PRO_3GEN_11 = "APP_IPAD_PRO_3GEN_11"
        APP_IPAD_PRO_129 = "APP_IPAD_PRO_129"
        APP_IPAD_PRO_3GEN_129 = "APP_IPAD_PRO_3GEN_129"

        IMESSAGE_APP_IPHONE_40 = "IMESSAGE_APP_IPHONE_40"
        IMESSAGE_APP_IPHONE_47 = "IMESSAGE_APP_IPHONE_47"
        IMESSAGE_APP_IPHONE_55 = "IMESSAGE_APP_IPHONE_55"
        IMESSAGE_APP_IPHONE_58 = "IMESSAGE_APP_IPHONE_58"
        IMESSAGE_APP_IPHONE_65 = "IMESSAGE_APP_IPHONE_65"

        IMESSAGE_APP_IPAD_97 = "IMESSAGE_APP_IPAD_97"
        IMESSAGE_APP_IPAD_105 = "IMESSAGE_APP_IPAD_105"
        IMESSAGE_APP_IPAD_PRO_129 = "IMESSAGE_APP_IPAD_PRO_129"
        IMESSAGE_APP_IPAD_PRO_3GEN_11 = "IMESSAGE_APP_IPAD_PRO_3GEN_11"
        IMESSAGE_APP_IPAD_PRO_3GEN_129 = "IMESSAGE_APP_IPAD_PRO_3GEN_129"

        APP_WATCH_SERIES_3 = "APP_WATCH_SERIES_3"
        APP_WATCH_SERIES_4 = "APP_WATCH_SERIES_4"

        APP_APPLE_TV = "APP_APPLE_TV"

        APP_DESKTOP = "APP_DESKTOP"

        ALL_IMESSAGE = [
          IMESSAGE_APP_IPHONE_40,
          IMESSAGE_APP_IPHONE_47,
          IMESSAGE_APP_IPHONE_55,
          IMESSAGE_APP_IPHONE_58,
          IMESSAGE_APP_IPHONE_65,

          IMESSAGE_APP_IPAD_97,
          IMESSAGE_APP_IPAD_105,
          IMESSAGE_APP_IPAD_PRO_129,
          IMESSAGE_APP_IPAD_PRO_3GEN_11,
          IMESSAGE_APP_IPAD_PRO_3GEN_129
        ]

        ALL = [
          APP_IPHONE_35,
          APP_IPHONE_40,
          APP_IPHONE_47,
          APP_IPHONE_55,
          APP_IPHONE_58,
          APP_IPHONE_65,

          APP_IPAD_97,
          APP_IPAD_105,
          APP_IPAD_PRO_3GEN_11,
          APP_IPAD_PRO_129,
          APP_IPAD_PRO_3GEN_129,

          IMESSAGE_APP_IPHONE_40,
          IMESSAGE_APP_IPHONE_47,
          IMESSAGE_APP_IPHONE_55,
          IMESSAGE_APP_IPHONE_58,
          IMESSAGE_APP_IPHONE_65,

          IMESSAGE_APP_IPAD_97,
          IMESSAGE_APP_IPAD_105,
          IMESSAGE_APP_IPAD_PRO_129,
          IMESSAGE_APP_IPAD_PRO_3GEN_11,
          IMESSAGE_APP_IPAD_PRO_3GEN_129,

          APP_WATCH_SERIES_3,
          APP_WATCH_SERIES_4,

          APP_DESKTOP
        ]
      end

      attr_mapping({
        "screenshotDisplayType" => "screenshot_display_type",

        "appScreenshots" => "app_screenshots"
      })

      def self.type
        return "appScreenshotSets"
      end

      def apple_tv?
        DisplayType::APP_APPLE_TV == screenshot_display_type
      end

      def imessage?
        DisplayType::ALL_IMESSAGE.include?(screenshot_display_type)
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resp = Spaceship::ConnectAPI.get_app_screenshot_sets(filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      def upload_screenshot(path: nil, wait_for_processing: true)
        return Spaceship::ConnectAPI::AppScreenshot.create(app_screenshot_set_id: id, path: path, wait_for_processing: wait_for_processing)
      end

      def reorder_screenshots(app_screenshot_ids: nil)
        Spaceship::ConnectAPI.patch_app_screenshot_set_screenshots(app_screenshot_set_id: id, app_screenshot_ids: app_screenshot_ids)

        return Spaceship::ConnectAPI.get_app_screenshot_set(app_screenshot_set_id: id, includes: "appScreenshots").first
      end
    end
  end
end
