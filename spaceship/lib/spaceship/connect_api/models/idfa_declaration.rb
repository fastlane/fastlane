require_relative '../model'
module Spaceship
  class ConnectAPI
    class IdfaDeclaration
      include Spaceship::ConnectAPI::Model

      attr_accessor :serves_ads
      attr_accessor :attributes_app_installation_to_previous_ad
      attr_accessor :attributes_action_with_previous_ad
      attr_accessor :honors_limited_ad_tracking

      module AppStoreAgeRating
        FOUR_PLUS = "FOUR_PLUS"
      end

      attr_mapping({
        "servesAds" => "serves_ads",
        "attributesAppInstallationToPreviousAd" => "attributes_app_installation_to_previous_ad",
        "attributesActionWithPreviousAd" => "attributes_action_with_previous_ad",
        "honorsLimitedAdTracking" => "honors_limited_ad_tracking"
      })

      def self.type
        return "idfaDeclarations"
      end

      #
      # API
      #

      def update(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        attributes = reverse_attr_mapping(attributes)
        client.patch_idfa_declaration(idfa_declaration_id: id, attributes: attributes)
      end

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_idfa_declaration(idfa_declaration_id: id)
      end
    end
  end
end
