require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppInfo
      include Spaceship::ConnectAPI::Model

      attr_accessor :app_store_state
      attr_accessor :state
      attr_accessor :app_store_age_rating
      attr_accessor :brazil_age_rating
      attr_accessor :kids_age_band

      attr_accessor :primary_category
      attr_accessor :primary_subcategory_one
      attr_accessor :primary_subcategory_two
      attr_accessor :secondary_category
      attr_accessor :secondary_subcategory_one
      attr_accessor :secondary_subcategory_two

      # Deprecated in App Store Connect API specification 3.3
      module AppStoreState
        ACCEPTED = "ACCEPTED"
        DEVELOPER_REJECTED = "DEVELOPER_REJECTED"
        DEVELOPER_REMOVED_FROM_SALE = "DEVELOPER_REMOVED_FROM_SALE"
        IN_REVIEW = "IN_REVIEW"
        INVALID_BINARY = "INVALID_BINARY"
        METADATA_REJECTED = "METADATA_REJECTED"
        PENDING_APPLE_RELEASE = "PENDING_APPLE_RELEASE"
        PENDING_CONTRACT = "PENDING_CONTRACT"
        PENDING_DEVELOPER_RELEASE = "PENDING_DEVELOPER_RELEASE"
        PREORDER_READY_FOR_SALE = "PREORDER_READY_FOR_SALE"
        PREPARE_FOR_SUBMISSION = "PREPARE_FOR_SUBMISSION"
        PROCESSING_FOR_APP_STORE = "PROCESSING_FOR_APP_STORE"
        READY_FOR_REVIEW = "READY_FOR_REVIEW"
        READY_FOR_SALE = "READY_FOR_SALE"
        REJECTED = "REJECTED"
        REMOVED_FROM_SALE = "REMOVED_FROM_SALE"
        REPLACED_WITH_NEW_VERSION = "REPLACED_WITH_NEW_VERSION"
        WAITING_FOR_EXPORT_COMPLIANCE = "WAITING_FOR_EXPORT_COMPLIANCE"
        WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
        NOT_APPLICABLE = "NOT_APPLICABLE"
      end

      module State
        ACCEPTED = "ACCEPTED"
        DEVELOPER_REJECTED = "DEVELOPER_REJECTED"
        IN_REVIEW = "IN_REVIEW"
        PENDING_RELEASE = "PENDING_RELEASE"
        PREPARE_FOR_SUBMISSION = "PREPARE_FOR_SUBMISSION"
        READY_FOR_DISTRIBUTION = "READY_FOR_DISTRIBUTION"
        READY_FOR_REVIEW = "READY_FOR_REVIEW"
        REJECTED = "REJECTED"
        REPLACED_WITH_NEW_INFO = "REPLACED_WITH_NEW_INFO"
        WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
      end

      module AppStoreAgeRating
        FOUR_PLUS = "FOUR_PLUS"
      end

      attr_mapping({
        "appStoreState" => "app_store_state",
        "state" => "state",
        "appStoreAgeRating" => "app_store_age_rating",
        "brazilAgeRating" => "brazil_age_rating",
        "kidsAgeBand" => "kids_age_band",

        "primaryCategory" => "primary_category",
        "primarySubcategoryOne" => "primary_subcategory_one",
        "primarySubcategoryTwo" => "primary_subcategory_two",
        "secondaryCategory" => "secondary_category",
        "secondarySubcategoryOne" => "secondary_subcategory_one",
        "secondarySubcategoryTwo" => "secondary_subcategory_two"
      })

      ESSENTIAL_INCLUDES = [
        "primaryCategory",
        "primarySubcategoryOne",
        "primarySubcategoryTwo",
        "secondaryCategory",
        "secondarySubcategoryOne",
        "secondarySubcategoryTwo"
      ].join(",")

      def self.type
        return "appInfos"
      end

      #
      # API
      #

      def update(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.patch_app_info(app_info_id: id).first
      end

      def update_categories(client: nil, category_id_map: nil)
        client ||= Spaceship::ConnectAPI
        client.patch_app_info_categories(app_info_id: id, category_id_map: category_id_map).first
      end

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_app_info(app_info_id: id)
      end

      #
      # Age Rating Declaration
      #

      def fetch_age_rating_declaration(client: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_age_rating_declaration(app_info_id: id)
        return resp.to_models.first
      end

      #
      # App Info Localizations
      #

      def create_app_info_localization(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_info_localization(app_info_id: id, attributes: attributes)
        return resp.to_models.first
      end

      def get_app_info_localizations(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_info_localizations(app_info_id: id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end
    end
  end
end
