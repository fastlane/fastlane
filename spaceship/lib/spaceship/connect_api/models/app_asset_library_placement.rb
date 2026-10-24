require_relative '../model'

module Spaceship
  class ConnectAPI
    class AppAssetLibraryPlacement
      include Spaceship::ConnectAPI::Model

      attr_mapping({
        'placementType' => 'placement_type',
        'placementGroup' => 'placement_group',
        'mediaType' => 'media_type',
        'state' => 'state',
        'stateDetails' => 'state_details',
        'image' => 'image',
        'video' => 'video'
      })

      def self.type
        return 'appAssetLibraryPlacements'
      end

      def self.all(client: nil, app_store_version_localization_id:, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        response = client.get_app_asset_library_placements(app_store_version_localization_id: app_store_version_localization_id, filter: filter, includes: includes, limit: limit, sort: sort)
        return response.all_pages.flat_map(&:to_models)
      end

      def self.create(client: nil, app_store_version_localization_id:, image_id: nil, video_id: nil, placement_type:, placement_group:)
        raise ArgumentError, 'Supply exactly one of image_id or video_id' unless [image_id, video_id].compact.size == 1

        client ||= Spaceship::ConnectAPI
        attributes = { placementType: placement_type, placementGroup: placement_group }
        media = image_id.nil? ? { video_id: video_id } : { image_id: image_id }
        return client.post_app_asset_library_placement(app_store_version_localization_id: app_store_version_localization_id, attributes: attributes, **media).first
      end

      # Placements are immutable; replacing their asset requires delete and create.
      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        return client.delete_app_asset_library_placement(app_asset_library_placement_id: id)
      end
    end
  end
end
