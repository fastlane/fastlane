require_relative '../model'

module Spaceship
  class ConnectAPI
    class AppAssetLibraryRefDatum
      include Spaceship::ConnectAPI::Model

      attr_mapping({
        'features' => 'features',
        'placementProfileGroups' => 'placement_profile_groups',
        'imageSpecs' => 'image_specs',
        'videoSpecs' => 'video_specs',
        'placementTypes' => 'placement_types',
        'displayClasses' => 'display_classes'
      })

      def self.type
        return 'appAssetLibraryRefData'
      end

      def self.all(client: nil, filter: {})
        client ||= Spaceship::ConnectAPI
        return client.get_app_asset_library_ref_data(filter: filter).to_models
      end
    end
  end
end
