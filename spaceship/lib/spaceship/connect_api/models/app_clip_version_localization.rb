require_relative '../model'

module Spaceship
  class ConnectAPI
    class AppClipVersionLocalization
      include Spaceship::ConnectAPI::Model

      attr_accessor :locale
      attr_accessor :subtitle

      attr_mapping(
        'locale' => 'locale',
        'subtitle' => 'subtitle',
        'appClipHeaderImage' => 'app_clip_header_image',
      )

      ESSENTIAL_INCLUDES = [
        'appClipHeaderImage'
      ].join(',')

      def self.type
        'appClipVersionLocalizations'
      end

      def get_app_clip_header_image(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_app_clip_header_images(app_clip_version_localization_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        resps.flat_map(&:to_models).first
      end

      def update(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        attributes = reverse_attr_mapping(attributes)
        client.patch_app_clip_version_localization(app_clip_version_localization_id: id, attributes: attributes)
      end

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        client.delete!(app_clip_version_localization_id: id)
      end
    end
  end
end
