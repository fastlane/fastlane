require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppDataUsage
      include Spaceship::ConnectAPI::Model

      attr_accessor :category
      attr_accessor :grouping
      attr_accessor :purpose
      attr_accessor :data_protection

      attr_mapping({
        "category" => "category",
        "grouping" => "grouping",
        "dataProtection" => "data_protection"
      })

      def self.type
        return "appDataUsages"
      end

      #
      # Helpers
      #

      def is_not_collected?
        return false unless data_protection
        return data_protection.id == "DATA_NOT_COLLECTED"
      end

      #
      # API
      #

      def self.all(app_id:, filter: {}, includes: nil, limit: nil, sort: nil)
        raise "app_id is required " if app_id.nil?

        resps = Spaceship::ConnectAPI.get_app_data_usages(app_id: app_id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.create(app_id:, app_data_usage_category_id: nil, app_data_usage_protection_id: nil, app_data_usage_purpose_id: nil)
        raise "app_id is required " if app_id.nil?

        resp = Spaceship::ConnectAPI.post_app_data_usage(
          app_id: app_id,
          app_data_usage_category_id: app_data_usage_category_id,
          app_data_usage_protection_id: app_data_usage_protection_id,
          app_data_usage_purpose_id: app_data_usage_purpose_id
        )
        return resp.to_models.first
      end

      def delete!
        Spaceship::ConnectAPI.delete_app_data_usage(app_data_usage_id: id)
      end
    end
  end
end
