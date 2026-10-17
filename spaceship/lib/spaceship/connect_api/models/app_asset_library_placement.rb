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
        'image' => 'image'
      })

      def self.type
        return 'appAssetLibraryPlacements'
      end

      def self.all(client: nil, app_store_version_localization_id:, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        response = client.get_app_asset_library_placements(app_store_version_localization_id: app_store_version_localization_id, filter: filter, includes: includes, limit: limit, sort: sort)
        return response.all_pages.flat_map(&:to_models)
      end

      def self.create(client: nil, app_store_version_localization_id:, image_id:, placement_type:, placement_group:)
        client ||= Spaceship::ConnectAPI
        attributes = { placementType: placement_type, placementGroup: placement_group }
        return client.post_app_asset_library_placement(app_store_version_localization_id: app_store_version_localization_id, image_id: image_id, attributes: attributes).first
      end

      # Placements are immutable; replacing their image requires delete and create.
      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        return client.delete_app_asset_library_placement(app_asset_library_placement_id: id)
      end
    end
  end
end
