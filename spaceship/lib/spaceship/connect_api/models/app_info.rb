require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppInfo
      include Spaceship::ConnectAPI::Model

      attr_accessor :app_store_state
      attr_accessor :app_store_age_rating
      attr_accessor :brazil_age_rating
      attr_accessor :kids_age_band

      module AppStoreState
        READY_FOR_SALE = "READY_FOR_SALE"
        WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
        DEVELOPER_REJECTED = "DEVELOPER_REJECTED"
        REJECTED = "REJECTED"
        PREPARE_FOR_SUBMISSION = "PREPARE_FOR_SUBMISSION"
      end

      module AppStoreAgeRating
        FOUR_PLUS = "FOUR_PLUS"
      end

      attr_mapping({
        "appStoreState" => "app_store_state",
        "appStoreAgeRating" => "app_store_age_rating",
        "brazilAgeRating" => "brazil_age_rating",
        "kidsAgeBand" => "kids_age_band"
      })

      def self.type
        return "appInfos"
      end

      #
      # API
      #

      def update(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.patch_app_info(app_info_id: id)
      end

      def update_categories(primary_category_id: nil, secondary_category_id: nil, primary_subcategory_one_id: nil, primary_subcategory_two_id: nil, secondary_subcategory_one_id: nil, secondary_subcategory_two_id: nil)
        Spaceship::ConnectAPI.patch_app_info_categories(
          app_info_id: id,
          primary_category_id: primary_category_id,
          secondary_category_id: secondary_category_id,
          primary_subcategory_one_id: primary_subcategory_one_id,
          primary_subcategory_two_id: primary_subcategory_two_id,
          secondary_subcategory_one_id: secondary_subcategory_one_id,
          secondary_subcategory_two_id: secondary_subcategory_two_id
        )
      end

      def delete!(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.delete_app_info(app_info_id: id)
      end

      #
      # App Info Localizations
      #

      def create_app_info_localization(attributes: nil)
        resp = Spaceship::ConnectAPI.post_app_info_localization(app_info_id: id, attributes: attributes)
        return resp.to_models.first
      end

      def get_app_info_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        return Spaceship::ConnectAPI.get_app_info_localizations(app_info_id: id, filter: filter, includes: includes, limit: limit, sort: sort)
      end
    end
  end
end
