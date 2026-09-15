require_relative '../model'
require_relative '../../errors'
module Spaceship
  class ConnectAPI
    class AppInfoLocalization
      include Spaceship::ConnectAPI::Model

      attr_accessor :locale
      attr_accessor :name
      attr_accessor :subtitle
      attr_accessor :privacy_policy_url
      attr_accessor :privacy_choices_url
      attr_accessor :privacy_policy_text

      attr_mapping({
        "locale" => "locale",
        "name" => "name",
        "subtitle" => "subtitle",
        "privacyPolicyUrl" => "privacy_policy_url",
        "privacyChoicesUrl" => "privacy_choices_url",
        "privacyPolicyText" => "privacy_policy_text"
      })

      def self.type
        return "appInfoLocalizations"
      end

      #
      # API
      #

      def update(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        attributes = reverse_attr_mapping(attributes)
        client.patch_app_info_localization(app_info_localization_id: id, attributes: attributes)
      rescue => error
        raise Spaceship::AppStoreLocalizationError.new(@locale, error)
      end

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_app_info_localization(app_info_localization_id: id)
      rescue => error
        raise Spaceship::AppStoreLocalizationError.new(@locale, error)
      end
    end
  end
end
