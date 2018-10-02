require_relative 'tunes_base'

module Spaceship
  module Tunes
    class Territory < TunesBase
      # @return (String) The two-character country code (e.g. "US" for the United States)
      attr_accessor :code

      # @return (String) The ISO 3166-1 alpha-3 currency code (e.g. "USD" for the United States)
      attr_accessor :currency_code

      # @return (String) The country name (e.g. "United States" for the United States)
      attr_accessor :name

      # @return (String) The region (e.g. "The United States and Canada" for the United States)
      attr_accessor :region

      # @return (String) The region locale key (e.g. "ITC.region.NAM" for the United States)
      attr_accessor :region_locale_key

      attr_mapping(
        'code' => :code,
        'currencyCodeISO3A' => :currency_code,
        'name' => :name,
        'region' => :region,
        'regionLocaleKey' => :region_locale_key
      )

      class << self
        # Create a new object based on a two-character country code (e.g. "US" for the United States)
        def from_code(code)
          obj = self.new
          obj.code = code
          return obj
        end
      end
    end
  end
end
