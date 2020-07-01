require_relative '../model'
require_relative './app_preview'

module Spaceship
  class ConnectAPI
    class AppPreviewSet
      include Spaceship::ConnectAPI::Model

      attr_accessor :preview_type

      attr_accessor :app_previews

      module PreviewType
        IPHONE_35 = "IPHONE_35"
        IPHONE_40 = "IPHONE_40"
        IPHONE_47 = "IPHONE_47"
        IPHONE_55 = "IPHONE_55"
        IPHONE_58 = "IPHONE_58"
        IPHONE_65 = "IPHONE_65"

        IPAD_97 = "IPAD_97"
        IPAD_105 = "IPAD_105"
        IPAD_PRO_3GEN_11 = "IPAD_PRO_3GEN_11"
        IPAD_PRO_129 = "IPAD_PRO_129"
        IPAD_PRO_3GEN_129 = "IPAD_PRO_3GEN_129"

        DESKTOP = "DESKTOP"

        ALL = [
          IPHONE_35,
          IPHONE_40,
          IPHONE_47,
          IPHONE_55,
          IPHONE_58,
          IPHONE_65,

          IPAD_97,
          IPAD_105,
          IPAD_PRO_3GEN_11,
          IPAD_PRO_129,
          IPAD_PRO_3GEN_129,

          DESKTOP
        ]
      end

      attr_mapping({
        "previewType" => "preview_type",

        "appPreviews" => "app_previews"
      })

      def self.type
        return "appPreviewSets"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resp = Spaceship::ConnectAPI.get_app_preview_sets(filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      def upload_preview(path: nil, frame_time_code: nil)
        return Spaceship::ConnectAPI::AppPreview.create(app_preview_set_id: id, path: path, frame_time_code: frame_time_code)
      end
    end
  end
end
