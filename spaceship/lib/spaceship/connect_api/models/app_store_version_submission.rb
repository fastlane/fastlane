require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppStoreVersionSubmission
      include Spaceship::ConnectAPI::Model

      attr_accessor :can_reject

      attr_mapping({
        "canReject" => "can_reject"
      })

      def self.type
        return "appStoreVersionSubmissions"
      end

      #
      # API
      #

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_app_store_version_submission(app_store_version_submission_id: id)
      end
    end
  end
end
