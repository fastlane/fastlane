require_relative 'tunes_base'

module Spaceship
  module Tunes
    class PricingInfo < TunesBase
      # @return (String) name of the country, e.g. "United States"
      attr_accessor :country

      # @return (String) country code, e.g. "US"
      attr_accessor :country_code

      # @return (String) currency symbol, e.g. "$"
      attr_accessor :currency_symbol

      # @return (String) currency code, e.g. "USD"
      attr_accessor :currency_code

      # @return (Number) net proceedings for the developer
      attr_accessor :wholesale_price

      # @return (Number) customer price
      attr_accessor :retail_price

      # @return (String) formatted customer price, e.g. "$0.00"
      attr_accessor :f_retail_price

      # @return (String) formatted net proceedings, e.g. "$0.00"
      attr_accessor :f_wholesale_price

      attr_mapping(
        'country' => :country,
        'countryCode' => :country_code,
        'currencySymbol' => :currency_symbol,
        'currencyCode' => :currency_code,
        'wholesalePrice' => :wholesale_price,
        'retailPrice' => :retail_price,
        'fRetailPrice' => :f_retail_price,
        'fWholesalePrice' => :f_wholesale_price
      )
    end
  end
end
