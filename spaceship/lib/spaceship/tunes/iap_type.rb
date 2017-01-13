module Spaceship
  module Tunes
    # Defines the different in-app purchase product types
    #
    # As specified by Apple: https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnectInAppPurchase_Guide/Chapters/CreatingInAppPurchaseProducts.html
    module IAPType
      # A product that is used once
      CONSUMABLE = "Consumable"

      # A product that is purchased once and does not expire or decrease with use.
      NON_CONSUMABLE = "Non-Consumable"

      # A product that allows users to purchase dynamic content for a set period (auto-rene).
      AUTO_RENEWABLE_SUBSCRIPTION = "Auto-Renewable Subscription"

      # A product that allows users to purchase a service with a limited duration.
      NON_RENEWING_SUBSCRIPTION = "Non-Renewing Subscription"

      # Get the iap type matching based on a string (given by iTunes Connect)
      def self.get_from_string(text)
        mapping = {
          'ITC.addons.type.consumable' => CONSUMABLE,
          'ITC.addons.type.nonConsumable' => NON_CONSUMABLE,
          'ITC.addons.type.recurring' => AUTO_RENEWABLE_SUBSCRIPTION,
          'ITC.addons.type.subscription' => NON_RENEWING_SUBSCRIPTION
        }

        mapping.each do |k, v|
          return v if k == text
        end

        return nil
      end
    end
  end
end
