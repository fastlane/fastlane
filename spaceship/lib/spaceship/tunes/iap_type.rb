module Spaceship
  module Tunes
    # Defines the different in-app purchase product types
    #
    # As specified by Apple: https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnectInAppPurchase_Guide/Chapters/CreatingInAppPurchaseProducts.html
    module IAPType
      CONSUMABLE = "consumable"
      NON_CONSUMABLE = "nonConsumable"
      RECURRING = "recurring"
      NON_RENEW_SUBSCRIPTION = "subscription"

      # A product that is used once
      READABLE_CONSUMABLE = "Consumable"

      # A product that is purchased once and does not expire or decrease with use.
      READABLE_NON_CONSUMABLE = "Non-Consumable"

      # A product that allows users to purchase dynamic content for a set period (auto-rene).
      READABLE_AUTO_RENEWABLE_SUBSCRIPTION = "Auto-Renewable Subscription"

      # A product that allows users to purchase a service with a limited duration.
      READABLE_NON_RENEWING_SUBSCRIPTION = "Non-Renewing Subscription"

      # Get the iap type matching based on a string (given by iTunes Connect)
      def self.get_from_string(text)
        mapping = {
          'ITC.addons.type.consumable' => READABLE_CONSUMABLE,
          'ITC.addons.type.nonConsumable' => READABLE_NON_CONSUMABLE,
          'ITC.addons.type.recurring' => READABLE_AUTO_RENEWABLE_SUBSCRIPTION,
          'ITC.addons.type.subscription' => READABLE_NON_RENEWING_SUBSCRIPTION,
          'consumable' => READABLE_CONSUMABLE,
          'nonConsumable' => READABLE_NON_CONSUMABLE,
          'recurring' => READABLE_AUTO_RENEWABLE_SUBSCRIPTION,
          'subscription' => READABLE_NON_RENEWING_SUBSCRIPTION
        }

        mapping.each do |itc_type, readable_type|
          return readable_type if itc_type == text
        end

        return nil
      end
    end
  end
end
