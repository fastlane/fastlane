require_relative '../model'

module Spaceship
  class ConnectAPI
    class ReviewRejection
      include Spaceship::ConnectAPI::Model

      attr_accessor :reasons

      attr_mapping({
        reasons: 'reasons'
      })

      def self.type
        return 'reviewRejections'
      end
    end
  end
end
