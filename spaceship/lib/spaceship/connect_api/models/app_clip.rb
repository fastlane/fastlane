require_relative '../model'

module Spaceship
  class ConnectAPI
    class AppClip
      include Spaceship::ConnectAPI::Model

      attr_accessor :bundle_id

      attr_mapping(
        'bundleId' => 'bundle_id',
      )

      def self.type
        'appClips'
      end

      def get_app_clip_versions(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_app_clip_versions(app_clip_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        resps.flat_map(&:to_models)
      end
    end
  end
end
