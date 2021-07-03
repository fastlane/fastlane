require_relative '../model'

module Spaceship
  class ConnectAPI
    class AppClipVersion
      include Spaceship::ConnectAPI::Model

      module InvocationVerb
        OPEN = 'OPEN'
        VIEW = 'VIEW'
        PLAY = 'PLAY'
      end

      attr_accessor :invocation_verb

      attr_mapping(
        'invocationVerb' => 'invocation_verb',
      )

      def self.type
        'appClipVersions'
      end

      def get_app_clip_version_localizations(client: nil, filter: {}, includes: Spaceship::ConnectAPI::AppClipVersionLocalization::ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_app_clip_version_localizations(app_clip_version_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        resps.flat_map(&:to_models)
      end

      def get_release_with_app_store_version(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_app_clip_version_release_with_app_store_version(app_clip_version_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        resps.flat_map(&:to_models)
      end

      def get_app_clip_app_store_review_detail(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_app_clip_app_store_review_detail(app_clip_version_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        resps.flat_map(&:to_models)
      end

      def create_app_store_version_localization(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        client.post_app_clip_version_localization(app_clip_version_id: id, attributes: attributes).first
      end

      def update(client: nil, attributes:)
        client ||= Spaceship::ConnectAPI
        client.patch_app_clip_version(app_clip_version_id: id, attributes: attributes).first
      end
    end
  end
end
