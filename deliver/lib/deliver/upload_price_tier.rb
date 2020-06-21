require_relative 'module'
require 'spaceship'

module Deliver
  # Set the app's pricing
  class UploadPriceTier
    def upload(options)
      return unless options[:price_tier]

      price_tier = options[:price_tier].to_s

      legacy_app = options[:app]
      app_id = legacy_app.apple_id
      app = Spaceship::ConnectAPI::App.get(app_id: app_id)

      app_prices = app.fetch_app_prices
      if app_prices.first
        old_price = app_prices.first.id
      end

      if price_tier == old_price
        UI.success("Price Tier unchanged (tier #{old_price})")
        return
      end

      app.update_app_price_tier(app_price_tier_id: price_tier)
      UI.success("Successfully updated the pricing from #{old_price} to #{price_tier}")
    end
  end
end
