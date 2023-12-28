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
        IPHONE_67 = "IPHONE_67"

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
          IPHONE_67,

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

      def self.all(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_preview_sets(filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      def self.get(client: nil, app_preview_set_id: nil, includes: "appPreviews")
        client ||= Spaceship::ConnectAPI
        return client.get_app_preview_set(app_preview_set_id: app_preview_set_id, filter: nil, includes: includes, limit: nil, sort: nil).first
      end

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        return client.delete_app_preview_set(app_preview_set_id: id)
      end

      def upload_preview(client: nil, path: nil, wait_for_processing: true, position: nil, frame_time_code: nil)
        client ||= Spaceship::ConnectAPI
        # Upload preview
        preview = Spaceship::ConnectAPI::AppPreview.create(client: client, app_preview_set_id: id, path: path, wait_for_processing: wait_for_processing, frame_time_code: frame_time_code)

        # Reposition (if specified)
        unless position.nil?
          # Get all app preview ids
          set = AppPreviewSet.get(app_preview_set_id: id)
          app_preview_ids = set.app_previews.map(&:id)

          # Remove new uploaded preview
          app_preview_ids.delete(preview.id)

          # Insert preview at specified position
          app_preview_ids = app_preview_ids.insert(position, preview.id).compact

          # Reorder previews
          reorder_previews(app_preview_ids: app_preview_ids)
        end

        return preview
      end

      def reorder_previews(client: nil, app_preview_ids: nil)
        client ||= Spaceship::ConnectAPI
        client.patch_app_preview_set_previews(app_preview_set_id: id, app_preview_ids: app_preview_ids)

        return client.get_app_preview_set(app_preview_set_id: id, includes: "appPreviews").first
      end
    end
  end
end
