require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaAppReviewSubmission
      include Spaceship::ConnectAPI::Model

      attr_accessor :beta_review_state

      attr_mapping({
        "betaReviewState" => "beta_review_state"
      })

      def self.type
        return "betaAppReviewSubmissions"
      end

      #
      # API
      #

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        return client.delete_beta_app_review_submission(beta_app_review_submission_id: id)
      end
    end
  end
end
