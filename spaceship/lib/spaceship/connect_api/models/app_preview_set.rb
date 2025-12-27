require_relative '../model'
require_relative './app_preview'

module Spaceship
  class ConnectAPI
    class AppPreviewSet
      include Spaceship::ConnectAPI::Model

      attr_accessor :preview_type

      attr_accessor :app_previews

      module PreviewType
        # https://developer.apple.com/documentation/appstoreconnectapi/previewtype
        IPHONE_35 = "IPHONE_35"  # not supported anymore
        IPHONE_40 = "IPHONE_40"  # 4"
        IPHONE_47 = "IPHONE_47"  # 4.7"
        IPHONE_55 = "IPHONE_55"  # 5.5"
        IPHONE_58 = "IPHONE_58"  # 6.1"
        IPHONE_61 = "IPHONE_61"  # 6.3"
        IPHONE_65 = "IPHONE_65"  # 6.5"
        IPHONE_67 = "IPHONE_67"  # 6.9"

        IPAD_97 = "IPAD_97" # 9.7"
        IPAD_105 = "IPAD_105" # 10.5"
        IPAD_PRO_129 = "IPAD_PRO_129" # 12.9"
        IPAD_PRO_3GEN_11 = "IPAD_PRO_3GEN_11" # 11"
        IPAD_PRO_3GEN_129 = "IPAD_PRO_3GEN_129" # 13"

        DESKTOP = "DESKTOP"

        ALL = [
          IPHONE_40,
          IPHONE_47,
          IPHONE_55,
          IPHONE_58,
          IPHONE_61,
          IPHONE_65,
          IPHONE_67,

          IPAD_97,
          IPAD_105,
          IPAD_PRO_129,
          IPAD_PRO_3GEN_11,
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

      # Validate video resolution (portrait canonical sizes) for provided preview_type.
      # Returns true if the resolution matches any accepted pair.
      def self.validate_video_resolution(width, height, preview_type)
        return false unless width && height
        if width > height
          width, height = height, width
        end
        # for a list of valid resolutions, look for "Accepted resolutions" at https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications
        # resolutions below are sorted by display inch from biggest to smallest (see top of the module)
        canonical = {
          # iPhone
          PreviewType::IPHONE_67 => [[886, 1920]],
          PreviewType::IPHONE_65 => [[886, 1920]],
          PreviewType::IPHONE_61 => [[886, 1920]],
          PreviewType::IPHONE_58 => [[886, 1920]],
          PreviewType::IPHONE_55 => [[1080, 1920]],
          PreviewType::IPHONE_47 => [[750, 1334]],
          PreviewType::IPHONE_40 => [[1080, 1920]],

          # iPad
          PreviewType::IPAD_PRO_3GEN_129 => [[1200, 1600]],
          PreviewType::IPAD_PRO_3GEN_11  => [[1200, 1600]],
          PreviewType::IPAD_PRO_129      => [[1200, 1600], [900, 1200]],
          PreviewType::IPAD_105          => [[1200, 1600]],
          PreviewType::IPAD_97           => [[900, 1200]],
        }

        pairs = canonical[preview_type] || []
        pairs.any? { |(canon_width, canon_height)| width == canon_width && height == canon_height }
      end

      def self.preview_type_from_filename(name, preview_types = PreviewType::ALL)
        preview_types.find { |type| name.to_s.upcase.include?(type) }
      end
    end
  end
end
