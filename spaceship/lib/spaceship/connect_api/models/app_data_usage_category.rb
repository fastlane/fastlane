require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppDataUsageCategory
      include Spaceship::ConnectAPI::Model

      attr_accessor :deleted

      attr_accessor :grouping

      attr_mapping({
        "deleted" => "deleted",

        "grouping" => "grouping"
      })

      def self.type
        return "appDataUsageCategories"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_app_data_usage_categories(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end
    end
  end
end
