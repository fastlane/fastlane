module Spaceship
  module Tunes
    # Defines the different in-app purchase intro offer types
    #
    # As specified by Apple: https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnectInAppPurchase_Guide/Chapters/CreatingInAppPurchaseProducts.html
    module IAPSubscriptionPricingIntroOfferType
      FREE_TRIAL = "FreeTrial"
      PAY_AS_YOU_GO = "PayAsYouGo"
      PAY_UP_FRONT = "PayUpFront"
    end
  end
end
