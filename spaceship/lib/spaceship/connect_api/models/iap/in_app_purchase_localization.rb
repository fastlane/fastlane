require_relative '../../model'
module Spaceship
  class ConnectAPI
    class InAppPurchaseLocalization
      include Spaceship::ConnectAPI::Model

      # Attributes
      attr_accessor :locale,
                    :name,
                    :description,
                    :state

      module State
        PREPARE_FOR_SUBMISSION = "PREPARE_FOR_SUBMISSION"
        WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
        APPROVED = "APPROVED"
        REJECTED = "REJECTED"
      end

      attr_mapping({
        description: 'description',
        locale: 'locale',
        name: 'name',
        state: 'state'
      })

      def self.type
        return 'inAppPurchaseLocalizations'
      end

      # Apple Developer API Docs: https://developer.apple.com/documentation/appstoreconnectapi/modify_an_in-app_purchase_localization
      def update(name: nil, description: nil)
        client ||= Spaceship::ConnectAPI
        name ||= self.name
        description ||= self.description
        resps = client.update_in_app_purchase_localization(localization_id: id, name: name, description: description)
        model = resps.to_models.first
        self.name = model.name
        self.description = model.description
        self.locale = model.locale
        self.state = model.state
      end

      #
      # Delete
      #

      def delete(client: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_in_app_purchase_localization(localization_id: id)
      end

    end
  end
end
