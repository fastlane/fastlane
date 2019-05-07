require_relative './model'
module Spaceship
  module ConnectAPI
    class BetaAppReviewSubmission
      include Spaceship::ConnectAPI::Model

      attr_accessor :beta_review_state

      attr_mapping({
        "betaReviewState" => "beta_review_state"
      })

      def self.type
        return "betaAppReviewSubmissions"
      end
    end
  end
end
