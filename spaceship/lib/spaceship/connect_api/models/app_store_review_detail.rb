require_relative '../model'
require_relative './app_review_attachment'

module Spaceship
  class ConnectAPI
    class AppStoreReviewDetail
      include Spaceship::ConnectAPI::Model

      attr_accessor :contact_first_name
      attr_accessor :contact_last_name
      attr_accessor :contact_phone
      attr_accessor :contact_email
      attr_accessor :demo_account_name
      attr_accessor :demo_account_password
      attr_accessor :demo_account_required
      attr_accessor :notes

      attr_mapping({
        "contactFirstName" => "contact_first_name",
        "contactLastName" => "contact_last_name",
        "contactPhone" => "contact_phone",
        "contactEmail" => "contact_email",
        "demoAccountName" => "demo_account_name",
        "demoAccountPassword" => "demo_account_password",
        "demoAccountRequired" => "demo_account_required",
        "notes" => "notes"
      })

      def self.type
        return "appStoreReviewDetails"
      end

      #
      # API
      #

      def fetch_app_review_attachments
        resp = Spaceship::ConnectAPI.fetch_app_review_attachments(app_store_review_detail_id: id)
        return resp.to_models
      end

      def update(attributes: nil)
        return Spaceship::ConnectAPI.patch_app_store_review_detail(app_store_review_detail_id: id, attributes: attributes)
      end

      def upload_attachment(path: nil)
        return Spaceship::ConnectAPI::AppReviewAttachment.create(app_store_review_detail_id: id, path: path)
      end
    end
  end
end
