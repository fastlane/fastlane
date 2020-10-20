require_relative '../model'
module Spaceship
  class ConnectAPI
    class ResetRatingsRequest
      include Spaceship::ConnectAPI::Model

      attr_accessor :reset_date

      attr_mapping({
        "resetDate" => "reset_date"
      })

      def self.type
        return "resetRatingsRequests"
      end

      #
      # API
      #

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_reset_ratings_request(reset_ratings_request_id: id)
      end
    end
  end
end
