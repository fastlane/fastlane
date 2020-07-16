require_relative 'module'
require 'spaceship'

module Deliver
  # Set the app's pricing
  class UploadPriceTier
    def upload(options)
      return unless options[:price_tier]

      price_tier = options[:price_tier].to_s

      app = options[:app]

      attributes = {}
      territory_ids = []

      app_prices = app.fetch_app_prices
      if app_prices.first
        old_price = app_prices.first.price_tier.id
      else
        UI.message("App has no prices yet... Enabling all countries in App Store Connect")
        territory_ids = Spaceship::ConnectAPI::Territory.all.map(&:id)
        attributes[:availableInNewTerritories] = true
      end

      if price_tier == old_price
        UI.success("Price Tier unchanged (tier #{old_price})")
        return
      end

      app.update(attributes: attributes, app_price_tier_id: price_tier, territory_ids: territory_ids)
      UI.success("Successfully updated the pricing from #{old_price} to #{price_tier}")
    end
  end
end
