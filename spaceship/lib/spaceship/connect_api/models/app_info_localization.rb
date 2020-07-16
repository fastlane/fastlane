require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppInfoLocalization
      include Spaceship::ConnectAPI::Model

      attr_accessor :locale
      attr_accessor :name
      attr_accessor :subtitle
      attr_accessor :privacy_policy_url
      attr_accessor :privacy_policy_text

      attr_mapping({
        "locale" => "locale",
        "name" => "name",
        "subtitle" => "subtitle",
        "privacyPolicyUrl" => "privacy_policy_url",
        "privacyPolicyText" => "privacy_policy_text"
      })

      def self.type
        return "appInfoLocalizations"
      end

      #
      # API
      #

      def update(attributes: nil)
        attributes = reverse_attr_mapping(attributes)
        Spaceship::ConnectAPI.patch_app_info_localization(app_info_localization_id: id, attributes: attributes)
      end

      def delete!(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.delete_app_info_localization(app_info_localization_id: id)
      end
    end
  end
end
