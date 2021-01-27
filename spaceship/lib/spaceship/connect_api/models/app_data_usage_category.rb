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

      # Found at https://appstoreconnect.apple.com/iris/v1/appDataUsageCategories
      module ID
        PAYMENT_INFORMATION = "PAYMENT_INFORMATION"
        CREDIT_AND_FRAUD = "CREDIT_AND_FRAUD"
        OTHER_FINANCIAL_INFO = "OTHER_FINANCIAL_INFO"
        PRECISE_LOCATION = "PRECISE_LOCATION"
        SENSITIVE_INFO = "SENSITIVE_INFO"
        PHYSICAL_ADDRESS = "PHYSICAL_ADDRESS"
        EMAIL_ADDRESS = "EMAIL_ADDRESS"
        NAME = "NAME"
        PHONE_NUMBER = "PHONE_NUMBER"
        OTHER_CONTACT_INFO = "OTHER_CONTACT_INFO"
        CONTACTS = "CONTACTS"
        EMAILS_OR_TEXT_MESSAGES = "EMAILS_OR_TEXT_MESSAGES"
        PHOTOS_OR_VIDEOS = "PHOTOS_OR_VIDEOS"
        AUDIO = "AUDIO"
        GAMEPLAY_CONTENT = "GAMEPLAY_CONTENT"
        CUSTOMER_SUPPORT = "CUSTOMER_SUPPORT"
        OTHER_USER_CONTENT = "OTHER_USER_CONTENT"
        BROWSING_HISTORY = "BROWSING_HISTORY"
        SEARCH_HISTORY = "SEARCH_HISTORY"
        USER_ID = "USER_ID"
        DEVICE_ID = "DEVICE_ID"
        PURCHASE_HISTORY = "PURCHASE_HISTORY"
        PRODUCT_INTERACTION = "PRODUCT_INTERACTION"
        ADVERTISING_DATA = "ADVERTISING_DATA"
        OTHER_USAGE_DATA = "OTHER_USAGE_DATA"
        CRASH_DATA = "CRASH_DATA"
        PERFORMANCE_DATA = "PERFORMANCE_DATA"
        OTHER_DIAGNOSTIC_DATA = "OTHER_DIAGNOSTIC_DATA"
        OTHER_DATA = "OTHER_DATA"
        HEALTH = "HEALTH"
        FITNESS = "FITNESS"
        COARSE_LOCATION = "COARSE_LOCATION"
      end

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
