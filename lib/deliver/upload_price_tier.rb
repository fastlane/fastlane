module Deliver
  # Set the app's pricing
  class UploadPriceTier
    def upload(options)
      return unless options[:price_tier]
      app = options[:app]

      # just to be sure, the user might have passed an int (which is fine with us)
      options[:price_tier] = options[:price_tier].to_s

      old_price = app.price_tier
      if options[:price_tier] == old_price
        Helper.log.info "Price Tier unchanged (tier #{options[:price_tier]})".green
        return
      end

      app.update_price_tier!(options[:price_tier])
      Helper.log.info "Successfully updated the pricing from #{old_price} to #{options[:price_tier]}".green
    end
  end
end
