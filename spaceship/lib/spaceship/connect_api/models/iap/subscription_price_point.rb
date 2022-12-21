require_relative '../../model'
module Spaceship
  class ConnectAPI
    class SubscriptionPricePoint
      include Spaceship::ConnectAPI::Model

      attr_accessor :customer_price
      attr_accessor :proceeds
      attr_accessor :proceeds_year2

      attr_mapping({
        customerPrice: 'customer_price',
        proceeds: 'proceeds',
        proceedsYear2: 'proceeds_year2',
      })

      def self.type
        return 'subscriptionPricePoints'
      end
    end
  end
end