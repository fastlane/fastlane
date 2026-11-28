require_relative '../model'
require_relative './review_submission_item'

module Spaceship
  class ConnectAPI
    class ReviewSubmission
      include Spaceship::ConnectAPI::Model

      attr_accessor :platform
      attr_accessor :state
      attr_accessor :submitted_date

      attr_accessor :app_store_version_for_review
      attr_accessor :items
      attr_accessor :last_updated_by_actor
      attr_accessor :submitted_by_actor

      module ReviewSubmissionState
        CANCELING = "CANCELING"
        COMPLETE = "COMPLETE"
        IN_REVIEW = "IN_REVIEW"
        READY_FOR_REVIEW = "READY_FOR_REVIEW"
        UNRESOLVED_ISSUES = "UNRESOLVED_ISSUES"
        WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
      end

      attr_mapping({
         "platform" => "platform",
         "state" => "state",
         "submittedDate" => "submitted_date",

         "appStoreVersionForReview" => "app_store_version_for_review",
         "items" => "items",
         "lastUpdatedByActor" => "last_updated_by_actor",
         "submittedByActor" => "submitted_by_actor",
       })

      def self.type
        return "reviewSubmissions"
      end

      #
      # API
      #

      # appStoreVersionForReview,items,submittedByActor,lastUpdatedByActor
      def self.get(client: nil, review_submission_id:, includes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_review_submission(review_submission_id: review_submission_id, includes: includes)
        return resp.to_models.first
      end

      def submit_for_review(client: nil)
        client ||= Spaceship::ConnectAPI
        attributes = { submitted: true }
        resp = client.patch_review_submission(review_submission_id: id, attributes: attributes)
        return resp.to_models.first
      end

      def cancel_submission(client: nil)
        client ||= Spaceship::ConnectAPI
        attributes = { canceled: true }
        resp = client.patch_review_submission(review_submission_id: id, attributes: attributes)
        return resp.to_models.first
      end

      def add_app_store_version_to_review_items(client: nil, app_store_version_id:)
        client ||= Spaceship::ConnectAPI
        resp = client.post_review_submission_item(review_submission_id: id, app_store_version_id: app_store_version_id)
        return resp.to_models.first
      end

      def fetch_resolution_center_threads(client: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_resolution_center_threads(filter: { reviewSubmission: id }, includes: 'reviewSubmission')
        return resp.to_models
      end

      def latest_resolution_center_messages(client: nil)
        client ||= Spaceship::ConnectAPI
        threads = fetch_resolution_center_threads(client: client)
        threads.first.fetch_messages(client: client)
      end
    end
  end
end
