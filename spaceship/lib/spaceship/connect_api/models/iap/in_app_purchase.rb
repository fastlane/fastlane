require_relative '../../model'
module Spaceship
  class ConnectAPI
    class InAppPurchase
      include Spaceship::ConnectAPI::Model

      attr_accessor :available_in_all_territories
      attr_accessor :content_hosting
      attr_accessor :family_sharable
      attr_accessor :in_app_purchase_type
      attr_accessor :name
      attr_accessor :product_id
      attr_accessor :review_note
      attr_accessor :state

      module Type
        CONSUMABLE = "CONSUMABLE"
        NON_CONSUMABLE = "NON_CONSUMABLE"
        NON_RENEWING_SUBSCRIPTION = "NON_RENEWING_SUBSCRIPTION"
      end

      module State
        APPROVED = "APPROVED"
        DEVELOPER_ACTION_NEEDED = "DEVELOPER_ACTION_NEEDED"
        DEVELOPER_REMOVED_FROM_SALE = "DEVELOPER_REMOVED_FROM_SALE"
        IN_REVIEW = "IN_REVIEW"
        MISSING_METADATA = "MISSING_METADATA"
        PENDING_BINARY_APPROVAL = "PENDING_BINARY_APPROVAL"
        PROCESSING_CONTENT = "PROCESSING_CONTENT"
        READY_TO_SUBMIT = "READY_TO_SUBMIT"
        REJECTED = "REJECTED"
        REMOVED_FROM_SALE = "REMOVED_FROM_SALE"
        WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
        WAITING_FOR_UPLOAD = "WAITING_FOR_UPLOAD"
      end

      attr_mapping({
        availableInAllTerritories: 'available_in_all_territories',
        contentHosting: 'content_hosting',
        familySharable: 'family_sharable',
        inAppPurchaseType: 'in_app_purchase_type',
        name: 'name',
        productId: 'product_id',
        reviewNote: 'review_note',
        state: 'state'
      })

      def self.type
        return 'inAppPurchases'
      end
    end
  end
end