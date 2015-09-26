module Deliver
  # Set the app's pricing
  class UploadPriceTier
    def upload(options)
      return unless options[:price_tier]

      app = options[:app]
      app.update_price_tier!(options[:price_tier])
      Helper.log.info "Successfully updated the pricing to tier #{options[:price_tier]}".green
    end
  end
end
